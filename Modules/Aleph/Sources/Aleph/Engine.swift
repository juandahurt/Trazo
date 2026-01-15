import MetalKit
import Tartarus

class Engine: NSObject {
    // MARK: Event queue
    var eventQueue: [Event] = []
    
    // MARK: Systems
    let transformSystem = TransformSystem()
    let layersSystem = LayersSystem()
    
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
                layers: [
                    .init(
                        named: "Background",
                        texture: TextureManager.makeTexture(
                            ofSize: canvasSize,
                            label: "Background texture"
                        )!
                    ),
                    .init(
                        named: "Layer 1",
                        texture: TextureManager.makeTexture(
                            ofSize: canvasSize,
                            label: "Layer 1 texture"
                        )!
                    )
                ],
                currentLayerIndex: -1
            ),
            dirtyContext: .init(dirtyIndices: [])
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
                case .rotation(anchor: let anchor, angle: let angle):
                    intents.append(.transform(.rotation(anchor: anchor, angle: angle)))
                }
            case .input(let inputEvent):
                switch inputEvent {
                case .touches(let touches): break
                }
            case .lifeCycle(let lifeCycleEvent):
                switch lifeCycleEvent {
                case .load:
                    intents.append(.layer(.fill(.white, 0)))
                    intents.append(.layer(.merge(.all)))
                }
            }
        }
        // 2. update
        for intent in intents {
            switch intent {
            case .transform(let transformIntent):
                transformSystem.update(ctx: &sceneContext, intent: transformIntent)
            case .layer(let layerIntent):
                layersSystem.update(ctx: &sceneContext, intent: layerIntent)
            }
        }
        // 3. build render plan
        let passes = planBuilder.buildPlan(ctx: &sceneContext)
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
    func buildPlan(ctx: inout SceneContext) -> [RenderPass] {
        var passes: [RenderPass] = []
       
        for operation in ctx.renderContext.operations {
            switch operation {
            case .fill(let color, let texture):
                passes.append(FillPass(color: color, textureId: texture))
            case .merge:
                passes.append(MergePass())
            }
        }
        ctx.renderContext.operations = []
        
        passes.append(PresentPass())
        return passes
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
