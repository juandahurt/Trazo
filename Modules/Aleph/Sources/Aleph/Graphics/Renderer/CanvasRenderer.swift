import MetalKit
import Tartarus

protocol FrameRequester: AnyObject {
    func requestFrame()
}

class CanvasRenderer {
    let strokeWorker = StrokeWorker()
    let frameScheduler = FrameScheduler()
    let commandExcecutor = CommandExcecutor()
    let renderResources: RenderResources
    
    weak var frameRequester: FrameRequester?
  
    init(canvasSize: Size) {
        renderResources = .init(canvasSize: canvasSize)
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
            frameScheduler.enqueue(.present)
            
            frameRequester?.requestFrame()
        }
    }
    
    func notifyChange() {
        frameScheduler.enqueue(.present)
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
    
    func fill(texture: TextureID, with color: Color) {
        frameScheduler.enqueue(.fill(texture, color))
    }
}
