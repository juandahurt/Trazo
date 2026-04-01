import MetalKit
import Tartarus

class Engine: NSObject {
    private var lastTime:           CFTimeInterval = 0
    private var isRunning:          Bool = false
    
    // MARK: Context
    var ctx:                        Context
   
    // MARK: Systems
    let strokeSystem:               StrokeSystem = .init()
    let renderSystem:               RenderSystem = .init()
    let animationSystem:            AnimationSystem = .init()
    let transformSystem:            TransformSystem = .init()
    lazy var systems:               [System] = {
        [strokeSystem, transformSystem, animationSystem, renderSystem]
    }()
    
    init(canvasSize: Size) {
        ctx = .init(
            clearColor: .init([0.062, 0.062, 0.066, 1]),
            canvasSize: canvasSize
        )
    }
    
    func ignite() {
        ctx.renderContext.enqueue(.fill(layerIndex: 0, color: .white))
        ctx.renderContext.enqueue(
            .mergeAllLayers(
                dirtyArea: .init(x: 0, y: 0, width: ctx.canvasSize.width, height: ctx.canvasSize.height)
            )
        )
        isRunning = true
    }
    
    func enqueue(_ action: Action) {
        switch action {
        case .stroke(let touch):
            strokeSystem.push(touch)
        case .layer(.fill(let index, let color)):
            ctx.renderContext.enqueue(.fill(layerIndex: index, color: color))
        case .layer(.merge(let dirtyArea)):
            ctx.renderContext.enqueue(.mergeAllLayers(dirtyArea: dirtyArea))
        case .transform(let transformType):
            let newTransform: Transform
            switch transformType {
            case .translate(dx: let dx, dy: let dy):
                newTransform = Transform(dx: dx, dy: dy)
            case .scale(let anchor, let scale):
                newTransform = Transform(anchor: anchor, scale: scale)
            case .rotate(let anchor, let rotation):
                newTransform = Transform(anchor: anchor, rotation: rotation)
            }
            transformSystem.enqueue(newTransform)
        }
    }
    
    func enqueue(_ animation: Animation) {
        ctx.liveAnimations.append(animation)
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
        systems.forEach { $0.update(dt: dt, ctx: ctx) }
//        if ctx.strokeContext.shouldClearStrokeGrid {
//            ctx.pendingPasses.append(
//                FillPass(
//                    color: .clear,
//                    tileGrid: ctx.strokeGrid
//                )
//            )
//            ctx.strokeContext.setShouldClearStrokeGrid(false)
//        }
//
//        
//        if ctx.strokeContext.shouldUpdateLayerGrid {
//            // TODO: not use the whole canvas here
//            let wholeCanvas = Rect(
//                x: 0,
//                y: 0,
//                width: ctx.canvasSize.width,
//                height: ctx.canvasSize.height
//            )
//            ctx.pendingPasses.append(
//                MergePass(
//                    dirtyArea: wholeCanvas,
//                    sourceGrids: [ctx.strokeGrid],
//                    destinationGrid: ctx.document.currentLayer.tileGrid,
//                    blitDestination: nil
//                )
//            )
//            ctx.strokeContext.setShouldUpdateLayerGrid(false)
//        }
    }
    
    @MainActor
    private func draw(_ view: MTKView) {
        render(view: view)
    }
    
    private func endFrame() {
        ctx.liveAnimations = ctx.liveAnimations.filter { $0.isAlive }
        ctx.pendingPasses = []
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
