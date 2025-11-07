import MetalKit
import Tartarus
import UIKit

class CanvasViewController: UIViewController {
    var state: CanvasState!
    let renderer = Renderer()
    let gestureController = GestureController()
    
    init(canvasSize: CGRect) {
        state = CanvasState(
            canvasSize: .init(
                width: Float(canvasSize.width),
                height: Float(canvasSize.height)
            )
        )
        
        super.init(nibName: nil, bundle: nil)
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
        renderer.fillTexture(state.renderableTexture!, color: .white)
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
        
        state.cpm = .init(
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
        encoder?.endEncoding()
        renderer.drawTiledTexture(
            state.renderableTexture!,
            on: drawable.texture,
            clearColor: [0, 0, 0, 0],
            transform: state.ctm,
            projection: state.cpm
        )
        renderer.present(drawable)
        renderer.commit()
        renderer.reset()
    }
}

extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        let touches = touches.map { Touch(touch: $0, in: view) }
        gestureController.handleFingerTouches(touches)
    }
}
