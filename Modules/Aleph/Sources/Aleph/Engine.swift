import MetalKit
import Tartarus

class Engine: NSObject {
    private var lastTime:           CFTimeInterval = 0
    private var isRunning:          Bool = false
    
    // MARK: Commands
    private var currentCommands:    [Command] = []
    private var nextCommands:       [Command] = []
    
    // MARK: Next frame
    private var liveAnimations:     [Animation] = []
    
    // MARK: Context
    var ctx:                        Context
   
    init(canvasSize: Size) {
        ctx = .init(
            clearColor: .init([0.95, 0.95, 0.95, 1]),
            canvasTexture: TextureManager.makeTexture(
                ofSize: canvasSize,
                label: "Canvas Texture"
            )!,
            canvasSize: canvasSize
        )
    }
    
    func ignite() {
        nextCommands.append(.layer(.fill(ctx.document.layers.first!.texture, .white)))
        nextCommands.append(
            .layer(
                .merge(
                    .init(
                        x: 0,
                        y: 0,
                        width: ctx.canvasSize.width,
                        height: ctx.canvasSize.height
                    )
                )
            )
        )
        isRunning = true
    }
    
    /// Enqueues a new command
    /// - Parameter command: Command to be executed in the next frame
    func enqueue(_ command: Command) {
        nextCommands.append(command)
    }
    
    /// Frame loop
    /// - Parameter dt: Delta time
    func tick(dt: Float, view: MTKView) {
        guard isRunning else { return }
        ctx.bufferAllocator.newFrame()
        update(dt)
        draw(view)
        endFrame()
    }
    
    private func update(_ dt: Float) {
        executePendingCommands()
        updateAnimations(dt: dt)
    }
    
    private func draw(_ view: MTKView) {
        guard !currentCommands.isEmpty else { return }
        render(view: view)
    }
    
    private func endFrame() {
        swapCommands()
        ctx.pendingPasses = []
    }
    
    private func swapCommands() {
        currentCommands = nextCommands
        nextCommands = []
    }
    
    private func executePendingCommands() {
        currentCommands.forEach { $0.instance.execute(context: ctx) }
    }
    
    private func updateAnimations(dt: Float) {
        liveAnimations = liveAnimations.filter {
            $0.update(dt: dt, ctx: ctx)
            return $0.isAlive
        }
    }
    
    func render(view: MTKView) {
        guard let commandBuffer = GPU.commandQueue.makeCommandBuffer() else { return }
        guard let drawable = view.currentDrawable else { return }
        
        ctx.pendingPasses.append(PresentPass())
        
        for p in ctx.pendingPasses {
            p.encode(
                commandBuffer: commandBuffer,
                drawable: drawable,
                ctx: ctx
            )
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension Engine: MTKViewDelegate {
    func draw(in view: MTKView) {
        let time = CACurrentMediaTime()
        let dt = lastTime != 0 ? Float(time - lastTime) : 0
        tick(dt: dt, view: view) // TODO: find actual delta time
        lastTime = time
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let rect = Rect(
            x: 0,
            y: 0,
            width: Float(size.width),
            height: Float(size.height)
        )
        ctx.projectionTransform = .init(
            ortho: rect,
            near: 0,
            far: 1
        )
    }
}
