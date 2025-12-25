import MetalKit
import Tartarus

protocol FrameRequester: AnyObject {
    func requestFrame()
}

struct LayersModel {
    var layers: [Layer]
    var currentLayerIndex: Int
    
    var visibleLayers: [Layer] {
        layers.filter { $0.isVisible }
    }
}

class CanvasRenderer {
    let strokeWorker = StrokeWorker()
    let frameScheduler = FrameScheduler()
    let commandExcecutor = CommandExcecutor()
    let renderResources: RenderResources
    let layersModel: LayersModel
    
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
        layersModel = .init(
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
        
        // fill background texture with white
        fill(texture: layersModel.layers.first!.texture, with: .white)
        // merge
        merge()
        // copy renderable texture to intermdiate texture
        frameScheduler.enqueue(.tileResolve(onlyDirtyIndices: false))
        // present
        frameScheduler.enqueue(.present)
    }
    
    func updateCurrentTransform(_ transform: Transform) {
        frameScheduler.updateCurrentTransform(transform)
    }
    
    func updateCurrentProjection(_ transform: Transform) {
        frameScheduler.updateCurrentProjection(transform)
    }
    
    func handleInput(_ touch: Touch) {
        strokeWorker.submit(touch) { [weak self] contribution in
            guard let self else { return }
            frameScheduler.ingest(contribution)
            frameScheduler.enqueue(.stroke)
            frameScheduler.enqueue(.tileResolve(onlyDirtyIndices: false))
            merge()
            frameScheduler.enqueue(.present)
            
            frameRequester?.requestFrame()
        }
    }
    
    func notifyChange() {
        frameRequester?.requestFrame()
    }
    
    func draw(drawable: CAMetalDrawable) {
        let passes = frameScheduler.buildFrameGraph()
        let context = frameScheduler.drain()
        commandExcecutor.excecute(
            passes: passes,
            context: context,
            renderResources: renderResources,
            drawable: drawable
        )
    }
    
    private func fill(texture: TextureID, with color: Color) {
        frameScheduler.enqueue(.fill(texture, color))
    }
    
    private func merge() {
        let visibleLayersIds = layersModel
            .visibleLayers
            .map { $0.texture }
        frameScheduler.enqueue(
            .merge(
                layers: visibleLayersIds,
                onlyDirtyIndices: false
            )
        )
    }
}
