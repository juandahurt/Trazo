import MetalKit
import Tartarus
import UIKit

class CanvasViewController: UIViewController {
    var state: CanvasState!
    let renderer = Renderer()
    let gestureController = GestureController()
    let transformer = Transformer()
    let currentTool = BrushTool()
    
    init(canvasSize: CGRect) {
        state = CanvasState(
            canvasSize: .init(
                width: Float(canvasSize.width),
                height: Float(canvasSize.height)
            )
        )
        
        super.init(nibName: nil, bundle: nil)
        
        currentTool.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        let canvasView = CanvasView()
        canvasView.delegate = self
        view = canvasView
    }
    
    override func viewDidLoad() {
        let fingerRecognizer = FingerGestureRecognizer()
        fingerRecognizer.fingerGestureDelegate = self
        view.addGestureRecognizer(fingerRecognizer)
        
        state.contentScaleFactor = Float(view.contentScaleFactor)
        setupCanvas()
        
        gestureController.delegate = self
    }
    
    func setupCanvas() {
        renderer.reset()
        state.renderableTexture = TextureManager.makeTiledTexture(
            named: "Renderable texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        state.grayscaleTexture = TextureManager.makeTiledTexture(
            named: "Grayscale texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        renderer.fillTexture(state.renderableTexture!, color: .white)
    }
    
    func drawPoints(points: [DrawablePoint]) {
        renderer
            .drawGrayscalePoints(points, on: state.grayscaleTexture!)
    }
}

extension CanvasViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let viewSize = Float(size.height)
        let aspect = Float(size.width) / Float(size.height)
        let rect = Rect(
            x: -viewSize * aspect * 0.5,
            y: Float(viewSize) * 0.5,
            width: Float(viewSize * aspect),
            height: Float(viewSize)
        )
        
        renderer.ctx.cpm = .init(
            ortho: rect,
            near: 0,
            far: 1
        )
    }

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let currentRenderPassDescriptor = view.currentRenderPassDescriptor
        else { return }
        let commandBuffer = GPU.commandQueue.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        print("drawing")
        encoder?.endEncoding()
        renderer.drawTiledTexture(
            state.renderableTexture!,
            on: drawable.texture,
            clearColor: .init([0.93, 0.93, 0.93, 1])
        )
        renderer.present(drawable)
        renderer.commit()
        renderer.reset()
    }
}

// MARK: - Gesture delegate
extension CanvasViewController: @preconcurrency GestureControllerDelegate {
    func gestureControllerDidStartTransform(
        _ controller: GestureController,
        touchesMap: [Int : [Touch]]
    ) {
        transformer.initialize(withTouches: touchesMap)
    }

    func gestureControllerDidTransform(
        _ controller: GestureController,
        touchesMap: [Int : [Touch]]
    ) {
        transformer.transform(currentTouches: touchesMap)
        renderer.ctx.ctm = transformer.transform
        view.setNeedsDisplay()
    }
    
    func gestureControllerDidStartPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        currentTool.handleFingerTouch(touch, ctm: renderer.ctx.ctm)
    }
    
    func gestureControllerDidPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        currentTool.handleFingerTouch(touch, ctm: renderer.ctx.ctm)
    }
}

// MARK: - Finger gesture delegate
extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        let touches = touches.map { Touch(touch: $0, in: view) }
        gestureController.handleFingerTouches(touches)
    }
}

// MARK: - Brush tool delegate
extension CanvasViewController: @preconcurrency BrushToolDelegate {
    func brushTool(_ tool: BrushTool, didGenerateSegments segments: [StrokeSegment]) {
        drawPoints(points: segments[0].points)
        view.setNeedsDisplay()
    }
}
