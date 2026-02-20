import MetalKit
import Tartarus

class Engine: NSObject {
    private var lastTime:           CFTimeInterval = 0
    private var isRunning:          Bool = false
    
    // MARK: Commands
    private var commands:    [Command] = []
    
    // MARK: Animations
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
            strokeTexture: TextureManager.makeTexture(
                ofSize: canvasSize,
                label: "Stroke Texture"
            )!,
            canvasSize: canvasSize
        )
    }
    
    func ignite() {
        commands.append(.layer(.fill(ctx.document.layers.first!.texture, .white)))
        commands.append(
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
        commands.append(command)
    }
    
    func enqueue(_ animation: Animation) {
        liveAnimations.append(animation)
    }
    
    /// Frame loop
    /// - Parameter dt: Delta time
    @MainActor
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
    
    @MainActor
    private func draw(_ view: MTKView) {
        guard !commands.isEmpty || !liveAnimations.isEmpty else { return }
        render(view: view)
    }
    
    private func endFrame() {
        liveAnimations = liveAnimations.filter { $0.isAlive }
        ctx.pendingPasses = []
        commands = []
    }
    
    private func executePendingCommands() {
        commands.forEach { $0.instance.execute(context: ctx) }
    }
    
    private func updateAnimations(dt: Float) {
        liveAnimations.forEach { $0.update(dt: dt, ctx: ctx) }
    }
    
    @MainActor
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
        
//        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//        guard let activeStroke = ctx.activeStroke else { return }
//        guard var lastTouch = activeStroke.touches.first else { return }
//        for touch in activeStroke.touches.dropFirst() {
//            let path = UIBezierPath()
//            path
//                .move(
//                    to: .init(
//                        x: CGFloat(lastTouch.location.x),
//                        y: CGFloat(lastTouch.location.y)
//                    )
//                )
//            path
//                .addLine(
//                    to: .init(
//                        x: CGFloat(touch.location.x),
//                        y: CGFloat(touch.location.y)
//                    )
//                )
//            let shape = CAShapeLayer()
//            shape.path = path.cgPath
//            shape.strokeColor = UIColor.blue.cgColor
//            let scale = view.contentScaleFactor
//            let scaleDown = CATransform3DMakeScale(1 / scale, 1 / scale, 1 / scale)
//            let transform = CATransform3DConcat(
//                ctx.cameraMatrix.caTransform3d(),
//                scaleDown
//            )
//            shape.transform = transform
//            view.layer.addSublayer(shape)
//            
//            let size = 5.0
//            let indicatorPath = UIBezierPath(
//                rect: .init(
//                    x: CGFloat(touch.location.x) - size / 2,
//                    y: CGFloat(touch.location.y) - size / 2,
//                    width: size,
//                    height: size
//                )
//            )
//            
//            let indicator = CAShapeLayer()
//            indicator.path = indicatorPath.cgPath
//            indicator.fillColor = UIColor.blue.cgColor
//            indicator.transform = transform
//            indicator.opacity = 0.5
//            
//            let pulse = CABasicAnimation()
//            pulse.fromValue = 0.5
//            pulse.toValue = 0
//            pulse.duration = 1
//            pulse.keyPath = "opacity"
//            pulse.isRemovedOnCompletion = false
//            pulse.repeatCount = .infinity
//            pulse.autoreverses = true
//            
//            let movement = CABasicAnimation()
//            movement.keyPath = "transform"
//            let toTranslation = CATransform3DMakeTranslation(
//                CGFloat(touch.location.x - lastTouch.location.x),
//                CGFloat(touch.location.y - lastTouch.location.y),
//                0
//            )
//            let toTransform = CATransform3DConcat(transform, toTranslation)
//            movement.fromValue = transform
//            movement.toValue = toTransform
//            movement.duration = 1
//            movement.autoreverses = true
//            movement.repeatCount = .infinity
//            
//            indicator.add(pulse, forKey: "pulse")
////            indicator.add(movement, forKey: "movement")
//            view.layer.addSublayer(indicator)
//            
//            lastTouch = touch
//        }
    }
}

extension Engine: MTKViewDelegate {
    func draw(in view: MTKView) {
        let time = CACurrentMediaTime()
        let dt = lastTime != 0 ? Float(time - lastTime) : 0
        tick(dt: dt, view: view)
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
