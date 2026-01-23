import MetalKit
import Tartarus

class Engine: NSObject {
    // MARK: Commands
    private var pendingCommands: [Command] = []
    
    // MARK: Context
    private var ctx: Context
    
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
    
    /// <#Description#>
    /// - Parameter dt: Delta time
    func tick(dt: Float, view: MTKView) {
        // execute pending commands
        pendingCommands.forEach { $0.execute(context: ctx) }
        
        pendingPasses.append(PresentPass())
        
        render(view: view)
        
        pendingCommands = []
        pendingPasses = []
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
        tick(dt: 0.16, view: view) // TODO: find actual delta time
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
