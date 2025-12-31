import MetalKit
import Tartarus

protocol FrameRequester: AnyObject {
    func requestFrame()
}

struct Layer {
    var name: String
    var isVisible = true
    var texture: TextureID
    
    init(named name: String, texture: TextureID) {
        self.name = name
        self.texture = texture
    }
}

struct CanvasState {
    var layers: [Layer]
    var currentLayerIndex: Int
    var selectedBrush: Brush
    
    var visibleLayers: [Layer] {
        layers.filter { $0.isVisible }
    }
    
    init(layers: [Layer], currentLayerIndex: Int) {
        self.layers = layers
        self.currentLayerIndex = currentLayerIndex
        selectedBrush = .init(
            shapeTextureID: TextureManager.loadTexture(
                fromFile: "default-shape",
                withExtension: "png"
            )!,
            spacing: 2,
            pointSize: 10
        )
    }
}

class CanvasRenderer: NSObject {
    let strokeWorker = StrokeWorker()
    let frameScheduler = FrameScheduler()
    let commandExcecutor = CommandExcecutor()
    let renderResources: RenderResources
    let canvasState: CanvasState
    
    weak var frameRequester: FrameRequester?
  
    init(canvasSize: Size) {
        let rows = 8
        let cols = 8
        let tileSize = Size(
            width: canvasSize.width / Float(cols),
            height: canvasSize.height / Float(rows)
        )
        renderResources = .init(
            canvasSize: canvasSize,
            tileSize: tileSize,
            rows: rows,
            cols: cols
        )
        canvasState = .init(
            layers: [
                .init(
                    named: "Background layer",
                    texture: TextureManager
                        .makeTiledTexture(
                            named: "Background texture",
                            rows: rows,
                            columns: cols,
                            tileSize: tileSize,
                            canvasSize: canvasSize
                        )
                ),
                .init(
                    named: "Layer 1",
                    texture: TextureManager
                        .makeTiledTexture(
                            named: "Layer 1 texture",
                            rows: rows,
                            columns: cols,
                            tileSize: tileSize,
                            canvasSize: canvasSize
                        )
                )
            ],
            currentLayerIndex: 1
        )
        super.init()
        
        // fill background texture with white
        fill(texture: canvasState.layers.first!.texture, with: .white)
        // merge
        merge(onlyDirtyTiles: false, isDrawing: false)
        // copy renderable texture to intermdiate texture
        frameScheduler.enqueue(.tileResolve(onlyDirtyIndices: false))
        // present
        frameScheduler.needsToPresent = true
    }
    
    func updateCurrentTransform(_ transform: Transform) {
        frameScheduler.updateCurrentTransform(transform)
        frameScheduler.needsToPresent = true
    }
    
    func updateCurrentProjection(_ transform: Transform) {
        frameScheduler.updateCurrentProjection(transform)
    }
    
    func handleInput(_ touch: Touch) {
        // TODO: find a better way to pass the bounding boxes
        let tiledTexture = TextureManager.findTiledTexture(
            id: canvasState.layers.first!.texture
        )!
        strokeWorker.submit(
            touch,
            ctm: frameScheduler.ctm,
            boundingBoxes: tiledTexture.tiles.map {
                $0.bounds
            },
            brush: canvasState.selectedBrush)
        { [weak self] contribution in
            guard let self else { return }
            frameScheduler.ingest(contribution)
            let visibleLayersIds = canvasState
                .visibleLayers
                .map { $0.texture }
            frameScheduler.enqueue(
                .stroke(
                    shape: canvasState.selectedBrush.shapeTextureID,
                    layers: visibleLayersIds,
                    currentLayerIndex: canvasState.currentLayerIndex
                )
            )
            
            frameRequester?.requestFrame()
        }
    }
    
    func notifyChange() {
        frameRequester?.requestFrame()
    }
    
    private func fill(texture: TextureID, with color: Color) {
        frameScheduler.enqueue(.fill(texture, color))
    }
    
    private func merge(onlyDirtyTiles: Bool, isDrawing: Bool) {
        let visibleLayersIds = canvasState
            .visibleLayers
            .map { $0.texture }
        frameScheduler.enqueue(
            .merge(
                layers: visibleLayersIds,
                onlyDirtyIndices: onlyDirtyTiles,
                isDrawing: isDrawing,
                currentLayerIndex: canvasState.currentLayerIndex
            )
        )
    }
}

extension CanvasRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let viewSize = Float(size.height)
        let aspect = Float(size.width) / Float(size.height)
        let rect = Rect(
            x: -viewSize * aspect * 0.5,
            y: Float(viewSize) * 0.5,
            width: Float(viewSize * aspect),
            height: Float(viewSize)
        )
        updateCurrentProjection(
            .init(
                ortho: rect,
                near: 0,
                far: 1
            )
        )
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        let passes = frameScheduler.buildFrameGraph()
        let context = frameScheduler.drain()
        commandExcecutor.excecute(
            passes: passes,
            context: context,
            renderResources: renderResources,
            drawable: drawable
        )
        
        // show bounding boxes of the segments
        var transform: CGAffineTransform = context.ctm.affineTransform()
        for segment in context.segments.filter { !$0.points.isEmpty } {
            let shape = CAShapeLayer()
            shape.path = .init(
                rect: .init(
                    x: Int(segment.bounds.x / 2) + Int(view.bounds.width / 2),
                    y: Int(-segment.bounds.y / 2) + Int(view.bounds.height / 2),
                    width: Int(segment.bounds.width) / 2,
                    height: Int(segment.bounds.height) / 2
                ),
                transform: &transform
            )
            shape.borderWidth = 1
            shape.strokeColor = UIColor.blue.withAlphaComponent(0.2).cgColor
            shape.fillColor = UIColor.blue.withAlphaComponent(0.2).cgColor
            shape.opacity = 0
            
            let fade = CABasicAnimation()
            fade.toValue = 0
            fade.fromValue = 1
            fade.duration = 0.3
            fade.keyPath = "opacity"
            shape.add(fade, forKey: "fadeOut")
            
            view.layer.addSublayer(shape)
        }
    }
}
