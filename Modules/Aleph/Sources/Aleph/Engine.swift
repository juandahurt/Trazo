import MetalKit
import Tartarus

class Engine: NSObject {
    // MARK: Event queue
    var eventQueue: [Event] = []
    
    // MARK: Systems
    let transformSystem = TransformSystem()
    
    // MARK: Rendering
    let planBuilder = RenderPlanBuilder()
    let planExecutor = RenderPlanExecutor()
    
    // MARK: Context/State
    var sceneContext: SceneContext
    
    init(canvasSize: Size) {
        let rows = 8
        let cols = 8
        let tileSize = Size(
            width: canvasSize.width / Float(cols),
            height: canvasSize.height / Float(rows)
        )
        sceneContext = .init(
            renderContext: .init(
                canvasSize: canvasSize,
                tileSize: tileSize,
                rows: rows,
                cols: cols
            ),
            layersContext: .init(
                layers: [],
                currentLayerIndex: -1
            )
        )
        eventQueue.append(.lifeCycle(.load))
    }
    
    func tick(in view: MTKView) {
        // 1. resolve intents
        var intents: [Intent] = []
        for e in eventQueue {
            switch e {
            case .transform(let transformEvent):
                switch transformEvent {
                case .translate(let x, let y):
                    intents.append(.transform(.translation(x: x, y: y)))
                case .zoom(anchor: let anchor, scale: let scale):
                    intents.append(.transform(.zoom(anchor: anchor, scale: scale)))
                }
            case .input(let inputEvent):
                switch inputEvent {
                case .touches(let touches): break
                }
            case .lifeCycle(let lifeCycleEvent):
                switch lifeCycleEvent {
                case .load:
                    intents.append(.layer(.merge(.all)))
                }
            }
        }
        // 2. update
        for intent in intents {
            switch intent {
            case .transform(let transformIntent):
                transformSystem.update(ctx: &sceneContext, intent: transformIntent)
            case .layer(let layerIntent): break
            }
        }
        // 3. build render plan
        let passes = planBuilder.buildPlan(ctx: sceneContext)
        // 4. render
        planExecutor.excecute(passes, ctx: sceneContext, drawable: view.currentDrawable!)
        // 5. end frame
        endFrame()
    }
    
    func enqueue(_ event: Event) {
        eventQueue.append(event)
    }
    
    func endFrame() {
        // clear events
        eventQueue = []
    }
}

extension Engine: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let rect = Rect(
            x: 0,
            y: 0,
            width: Float(size.width),
            height: Float(size.height)
        )
        sceneContext.renderContext.projectionTransform = .init(
            ortho: rect,
            near: 0,
            far: 1
        )
    }
    
    func draw(in view: MTKView) {
        tick(in: view)
    }
}

class RenderPlanBuilder {
    func buildPlan(ctx: SceneContext) -> [RenderPass] {
        [PresentPass()]
    }
}

class RenderPlanExecutor {
    func excecute(_ passes: [RenderPass], ctx: SceneContext, drawable: CAMetalDrawable) {
        guard let commandBuffer = GPU.commandQueue.makeCommandBuffer() else { return }
        for pass in passes {
            pass.encode(
                context: ctx,
                commandBuffer: commandBuffer,
                drawable: drawable
            )
        }
        commandBuffer.commit()
    }
}
