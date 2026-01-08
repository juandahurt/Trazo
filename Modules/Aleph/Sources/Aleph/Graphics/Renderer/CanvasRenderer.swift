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
            shapeTextureID: .max, // just a wrong number while we pass the selected brush
            granularityTextureID: .max,
            spacing: 2,
            pointSize: 10,
            opacity: 1
        )
    }
}

class CanvasRenderer: NSObject {
    let strokeWorker = StrokeWorker()
    let frameScheduler = FrameScheduler()
    let commandExcecutor = CommandExcecutor()
    let renderResources: RenderResources
    var canvasState: CanvasState
    
    weak var frameRequester: FrameRequester?
  
    init(canvasSize: Size) {
        let rows = 41
        let cols = 59
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
            brush: canvasState.selectedBrush,
            tileSize: renderResources.tileSize,
            rows: renderResources.rows,
            cols: renderResources.cols)
        { [weak self] contribution in
            guard let self else { return }
            frameScheduler.ingest(contribution)
            let visibleLayersIds = canvasState
                .visibleLayers
                .map { $0.texture }
            frameScheduler.enqueue(
                .stroke(
                    shape: canvasState.selectedBrush.shapeTextureID,
                    granularity: canvasState.selectedBrush.granularityTextureID,
                    layers: visibleLayersIds,
                    currentLayerIndex: canvasState.currentLayerIndex
                )
            )
            frameScheduler.needsToPresent = true
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
        let rect = Rect(
            x: 0,
            y: 0,
            width: Float(size.width),
            height: Float(size.height)
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
        var context = frameScheduler.drain()
        context.opacity = canvasState.selectedBrush.opacity
        commandExcecutor.excecute(
            passes: passes,
            context: context,
            renderResources: renderResources,
            drawable: drawable
        )
        
//        frameScheduler.needsToPresent = false
        
        // show bounding boxes of the segments
//        var transform: CGAffineTransform = .identity
//        for segment in context.segments.filter { !$0.points.isEmpty } {
//            let shape = CAShapeLayer()
//            shape.path = .init(
//                rect: .init(
//                    x: Int(segment.bounds.x) / 2,
//                    y: Int(segment.bounds.y) / 2,
//                    width: Int(segment.bounds.width) / 2,
//                    height: Int(segment.bounds.height) / 2
//                ),
//                transform: &transform
//            )
//            shape.borderWidth = 1
//            shape.strokeColor = UIColor.blue.withAlphaComponent(0.2).cgColor
//            shape.fillColor = UIColor.blue.withAlphaComponent(0.2).cgColor
//            shape.opacity = 0
//            
//            let fade = CABasicAnimation()
//            fade.toValue = 0
//            fade.fromValue = 1
//            fade.duration = 0.3
//            fade.keyPath = "opacity"
//            shape.add(fade, forKey: "fadeOut")
//            
//            view.layer.addSublayer(shape)
//        }
    }
}
