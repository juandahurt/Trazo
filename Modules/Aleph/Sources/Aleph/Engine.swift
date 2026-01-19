import MetalKit
import Tartarus

import Caravaggio

class Engine: NSObject {
    // MARK: Event queue
    var eventQueue: [Event] = []
    
    // MARK: Systems
    let transformSystem = TransformSystem()
    let layersSystem = LayersSystem()
    let strokeSystem = StrokeSystem()
    let tileSystem = TileSystem()
    
    // MARK: Rendering
    let planBuilder = RenderPlanBuilder()
    let planExecutor = RenderPlanExecutor()
    
    // MARK: Context/State
    var sceneContext: SceneContext
    
    init(canvasSize: Size) {
        let tileSize = Size(
            width: 64,
            height: 64
        )
        let rows = Int(ceil(canvasSize.height / tileSize.height))
        let cols = Int(ceil(canvasSize.width / tileSize.width))
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
                currentLayerIndex: 1
            ),
            dirtyContext: .init(dirtyIndices: []),
            strokeContext: StrokeContext()
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
            case .touch(let touchEvent):
                switch touchEvent {
                case .finger(let touch):
                    intents.append(.draw(touch))
                }
            case .lifeCycle(let lifeCycleEvent):
                switch lifeCycleEvent {
                case .load:
                    intents.append(.layer(.invalidate))
                    intents.append(.layer(.fill(.white, 0)))
                    intents.append(.layer(.merge))
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
            case .draw(let touch):
                strokeSystem.update(ctx: &sceneContext, touch: touch)
                tileSystem.update(ctx: &sceneContext)
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
        sceneContext.dirtyContext.dirtyIndices = []
        sceneContext.strokeContext.segments = [] // clean segments
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
            case .merge(let isDrawing):
                passes.append(MergePass(isDrawing: isDrawing))
            case .draw(let segment):
                passes.append(StrokePass(segment: segment))
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
