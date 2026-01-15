import MetalKit
import Tartarus
import UIKit

public class CanvasViewController: UIViewController {
    let canvasSize: Size
    var engine: Engine?
    
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
        let fingerRecognizer = FingerGestureRecognizer()
        fingerRecognizer.fingerGestureDelegate = self
        view.addGestureRecognizer(fingerRecognizer)
        let pencilRecognizer = PencilGestureRecognizer()
        pencilRecognizer.pencilGestureDelegate = self
        view.addGestureRecognizer(pencilRecognizer)
        
        // MARK: Transforms gestures
        var transformGestures: [UIGestureRecognizer] = []
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(onPanGesture(_:))
        )
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
        for gesture in transformGestures {
            gesture.delegate = self
            view.addGestureRecognizer(gesture)
        }
        
        engine = .init(
            canvasSize: canvasSize * Float(view.contentScaleFactor)
        )
        (view as? MTKView)?.delegate = engine
    }
}

extension CanvasViewController {
    @objc
    func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        engine?.enqueue(
            .transform(
                .translate(
                    x: Float(translation.x) * Float(view.contentScaleFactor),
                    y: Float(translation.y) * Float(view.contentScaleFactor)
                )
            )
        )
        gesture.setTranslation(.zero, in: view)
    }
    
    @objc
    func onPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let anchor = gesture.location(in: view)
        let scale = Float(gesture.scale)
        engine?.enqueue(
            .transform(
                .zoom(
                    anchor: .init(
                        x: Float(anchor.x),
                        y:  Float(anchor.y)
                    ) * Float(view.contentScaleFactor),
                    scale: scale
                )
            )
        )
        gesture.scale = 1
    }
    
    @objc
    func onRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        let anchor = gesture.location(in: view)
        engine?.enqueue(
            .transform(
                .rotation(
                    anchor: .init(
                        x: Float(anchor.x),
                        y:  Float(anchor.y)
                    ) * Float(view.contentScaleFactor),
                    angle: Float(-gesture.rotation)
                )
            )
        )
        gesture.rotation = 0
    }
}

extension CanvasViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: - Finger gesture delegate
extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        guard let engine else { return }
        let touches = touches.map { Touch(touch: $0, in: view) }
        engine.enqueue(.input(.touches(touches)))
//        renderer.collectInput(touches)
//        gestureController.handleFingerTouches(touches)
    }
}

extension CanvasViewController: PencilGestureRecognizerDelegate {
    func didReceivePencilTouches(_ touches: Set<UITouch>) {
        // TODO: finish implementation
//        let touches = touches.map { Touch(touch: $0, in: view) }
//        for touch in touches {
//            renderer?.handleInput(touch)
//        }
    }
}

// MARK: - API
public extension CanvasViewController {
    func setSpacing(_ value: Float) {
//        renderer?.canvasState.selectedBrush.spacing = value
    }
    
    func setPointSize(_ value: Float) {
//        renderer?.canvasState.selectedBrush.pointSize = value
    }
    
    func setOpacity(_ value: Float) {
//        renderer?.canvasState.selectedBrush.opacity = value
    }
    
    func setShapeTexture(_ id: TextureID) {
//        renderer?.canvasState.selectedBrush.shapeTextureID = id
    }
    
    func setGranularityTexture(_ id: TextureID) {
//        renderer?.canvasState.selectedBrush.granularityTextureID = id
    }
}
