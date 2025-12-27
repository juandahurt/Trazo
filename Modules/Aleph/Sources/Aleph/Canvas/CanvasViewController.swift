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
        view = canvasView
    }
    
    override func viewDidLoad() {
        gestureController.delegate = self
        let fingerRecognizer = FingerGestureRecognizer()
        fingerRecognizer.fingerGestureDelegate = self
        view.addGestureRecognizer(fingerRecognizer)
        let pencilRecognizer = PencilGestureRecognizer()
        pencilRecognizer.pencilGestureDelegate = self
        view.addGestureRecognizer(pencilRecognizer)
        
        renderer = .init(
            canvasSize: canvasSize * Float(view.contentScaleFactor)
        )
        (view as? MTKView)?.delegate = renderer
        guard let renderer else { return }
        renderer.frameRequester = self
        renderer.notifyChange()
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

extension CanvasViewController: PencilGestureRecognizerDelegate {
    func didReceivePencilTouches(_ touches: Set<UITouch>) {
        // TODO: finish implementation
        let touches = touches.map { Touch(touch: $0, in: view) }
        for touch in touches {
            renderer?.handleInput(touch)
        }
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
