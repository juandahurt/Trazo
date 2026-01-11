import MetalKit
import Tartarus

class Engine: NSObject {
    let inputSystem = InputSystem()
    let intentSystem = IntentSystem()
    let transformSystem = TransformSystem()
    
    let planBuilder = RenderPlanBuilder()
    let planExcecutor = RenderPlanExcecutor()
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
            )
        )
    }
    
    func tick(in view: MTKView) {
        print("begin frame")
        // 1. resolve intents
        let pendingInput = inputSystem.drain()
        let intents = intentSystem.resolve(pendingInput)
        // 2. update
        for intent in intents {
            switch intent {
            case .transform(let transformIntent, let touchMap):
                switch transformIntent {
                case .start:
                    transformSystem.reset(ctx: &sceneContext, touchMap: touchMap)
                case .update:
                    transformSystem.update(ctx: &sceneContext, touchMap: touchMap)
                }
            case .unknown:
                print("unknown")
            }
        }
        // 3. build render plan
        let passes = planBuilder.buildPlan(ctx: sceneContext, intents: intents)
        
        // 4. excecute plan
        planExcecutor.excecute(passes, ctx: sceneContext, drawable: view.currentDrawable!)
        print("end frame")
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
    func buildPlan(ctx: SceneContext, intents: [InputIntent]) -> [RenderPass] {
        [PresentPass()]
    }
}

class RenderPlanExcecutor {
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
