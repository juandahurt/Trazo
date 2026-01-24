import MetalKit
import Tartarus

class Engine: NSObject {
    private var lastTime: CFTimeInterval = 0
    // MARK: Next frame
    private var pendingCommands: [Command] = []
    private var liveAnimations: [Animation] = []
    
    // MARK: Context
    var ctx: Context
    
    // MARK: Rendering
    private var pendingPasses: [Pass] = []
   
    init(canvasSize: Size) {
        ctx = .init(
            clearColor: .blue,
            canvasTexture: TextureManager.makeTexture(ofSize: canvasSize)!,
            canvasSize: canvasSize
        )
    }
    
    /// <#Description#>
    /// - Parameter command: <#command description#>
    func enqueue(_ command: Command) {
        pendingCommands.append(command)
    }
    
    /// Frame loop
    /// - Parameter dt: Delta time
    func tick(dt: Float, view: MTKView) {
        ctx.bufferAllocator.newFrame()
        
        executePendingCommands()
        updateAnimations(dt: dt)
        
        pendingPasses.append(PresentPass())
        
        render(view: view)
        
        pendingCommands = []
        pendingPasses = []
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
        
        for p in pendingPasses {
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
