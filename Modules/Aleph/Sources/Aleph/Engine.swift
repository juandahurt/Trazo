import MetalKit
import Tartarus

class Engine: NSObject {
    private var lastTime:           CFTimeInterval = 0
    private var isRunning:          Bool = false
    
    // MARK: Next frame
    private var pendingCommands:    [Command] = []
    private var liveAnimations:     [Animation] = []
    
    // MARK: Context
    var ctx:                        Context
   
    init(canvasSize: Size) {
        ctx = .init(
            clearColor: .init([0.95, 0.95, 0.95, 1]),
            canvasTexture: TextureManager.makeTexture(ofSize: canvasSize)!,
            canvasSize: canvasSize
        )
    }
    
    func ignite() {
        pendingCommands.append(
            FillCommand(
                color: .white,
                texture: ctx.document.currentLayer.texture
            )
        )
        isRunning = true
    }
    
    /// Enqueues a new command
    /// - Parameter command: Command to be executed in the next frame
    func enqueue(_ command: Command) {
        pendingCommands.append(command)
    }
    
    /// Frame loop
    /// - Parameter dt: Delta time
    func tick(dt: Float, view: MTKView) {
        guard isRunning else { return }
        ctx.bufferAllocator.newFrame()
        
        executePendingCommands()
        updateAnimations(dt: dt)
        
        ctx.pendingPasses.append(PresentPass())
        
        render(view: view)
        
        pendingCommands = []
        ctx.pendingPasses = []
    }
    
    private func executePendingCommands() {
        pendingCommands.forEach { $0.execute(context: ctx) }
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
        
        for p in ctx.pendingPasses {
            p.encode(
                commandBuffer: commandBuffer,
                drawable: drawable,
                ctx: ctx
            )
        }
        
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
