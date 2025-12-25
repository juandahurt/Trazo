import MetalKit
import Tartarus
import UIKit

class CanvasViewController: UIViewController {
    let gestureController = GestureController()
    let transformer = Transformer()
    var renderer: CanvasRenderer?
    
    let canvasSize: Size
    
    init(canvasSize: CGRect) {
        self.canvasSize = .init(
            width: Float(canvasSize.width),
            height: Float(canvasSize.height)
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
        gestureController.delegate = self
        let fingerRecognizer = FingerGestureRecognizer()
        fingerRecognizer.fingerGestureDelegate = self
        view.addGestureRecognizer(fingerRecognizer)
        
        renderer = .init(
            canvasSize: canvasSize * Float(view.contentScaleFactor)
        )
        guard let renderer else { return }
        renderer.frameRequester = self
        renderer.notifyChange()
    }
}

extension CanvasViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let renderer else { return }
        let viewSize = Float(size.height)
        let aspect = Float(size.width) / Float(size.height)
        let rect = Rect(
            x: -viewSize * aspect * 0.5,
            y: Float(viewSize) * 0.5,
            width: Float(viewSize * aspect),
            height: Float(viewSize)
        )
        renderer.updateCurrentProjection(
            .init(
                ortho: rect,
                near: 0,
                far: 1
            )
        )
    }
    
    func draw(in view: MTKView) {
        guard let renderer else { return }
        guard let drawable = view.currentDrawable else { return }
        renderer.draw(drawable: drawable)
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
        guard let renderer else { return }
        transformer.transform(currentTouches: touchesMap)
        renderer.updateCurrentTransform(transformer.transform)
        renderer.notifyChange()
    }
    
    func gestureControllerDidStartPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        renderer?.handleInput(touch)
    }
    
    func gestureControllerDidPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        renderer?.handleInput(touch)
    }
}

// MARK: - Finger gesture delegate
extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        let touches = touches.map { Touch(touch: $0, in: view) }
        gestureController.handleFingerTouches(touches)
    }
}

extension CanvasViewController: @MainActor FrameRequester {
    func requestFrame() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            view.setNeedsDisplay()
        }
    }
}
