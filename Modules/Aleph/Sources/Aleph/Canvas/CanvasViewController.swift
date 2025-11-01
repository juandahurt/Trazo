import MetalKit
import UIKit

class CanvasViewController: UIViewController {
    var state: CanvasState!
    
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
        state.renderableTexture = TextureManager.makeTiledTexture(
            named: "Renderable texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
    }
}

extension CanvasViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(size)
    }

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let currentRenderPassDescriptor = view.currentRenderPassDescriptor
        else { return }
        let commandBuffer = GPU.commandQueue.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        print("touch")
        // check gesture type
        // if transform: transform the canvas and render it
        // if draw: run the draw workflow and render the canvas
    }
}
