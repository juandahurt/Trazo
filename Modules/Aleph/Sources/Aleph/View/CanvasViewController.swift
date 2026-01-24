import MetalKit
import Tartarus
import UIKit

public class CanvasViewController: UIViewController {
    let canvasSize: Size
    var engine: Engine?
    
    var simultaneosGestures: [UIGestureRecognizer] = []
    
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
    
    public override func loadView() {
        let canvasView = CanvasView()
        view = canvasView
    }
    
    public override func viewDidLoad() {
        // MARK: Transforms gestures
        var transformGestures: [UIGestureRecognizer] = []
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(onPanGesture(_:))
        )
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        transformGestures.append(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(onPinchGesture(_:))
        )
        transformGestures.append(pinchGesture)
        let rotationGesture = UIRotationGestureRecognizer(
            target: self,
            action: #selector(onRotationGesture(_:))
        )
        transformGestures.append(rotationGesture)
        
        // MARK: Draw gesture
//        let drawGesture = FingerGestureRecognizer(
//            target: self,
//            action: #selector(onDrawGesture(_:))
//        )
//        drawGesture.minimumNumberOfTouches = 1
//        drawGesture.maximumNumberOfTouches = 1
//        view.addGestureRecognizer(drawGesture)
        
        for gesture in transformGestures {
            gesture.delegate = self
            view.addGestureRecognizer(gesture)
            simultaneosGestures.append(gesture)
        }
        
        engine = .init(
            canvasSize: canvasSize * Float(view.contentScaleFactor)
        )
        (view as? MTKView)?.delegate = engine
    }
}

extension CanvasViewController {
    @objc
    func onDrawGesture(_ gesture: UIPanGestureRecognizer) {
//        let touch = Touch(gesture: gesture, in: view)
//        engine?.enqueue(.touch(.finger(touch)))
    }
    
    @objc
    func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let dx = Float(translation.x * view.contentScaleFactor)
        let dy = Float(translation.y * view.contentScaleFactor)
        engine?.enqueue(TransformCommand.translate(dx: dx, dy: dy))
        gesture.setTranslation(.zero, in: view)
    }
    
    @objc
    func onPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        var location = gesture.location(in: view)
        let anchor = Point(
            x: Float(location.x * view.contentScaleFactor),
            y: Float(location.x * view.contentScaleFactor)
        )
        let scale = Float(gesture.scale)
        engine?.enqueue(TransformCommand.pinch(anchor: anchor, scale: scale))
        gesture.scale = 1
    }
    
    @objc
    func onRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        var location = gesture.location(in: view)
        let anchor = Point(
            x: Float(location.x * view.contentScaleFactor),
            y: Float(location.x * view.contentScaleFactor)
        )
        let angle = Float(gesture.rotation)
        engine?.enqueue(TransformCommand.rotate(anchor: anchor, angle: angle))
        gesture.rotation = 0
    }
}

extension CanvasViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        simultaneosGestures.contains(gestureRecognizer) &&
        simultaneosGestures.contains(otherGestureRecognizer)
    }
}

// MARK: - API
public extension CanvasViewController {
    func setBrush(_ brush: Brush) {
//        engine?.enqueue(.brush(brush))
    }
}
