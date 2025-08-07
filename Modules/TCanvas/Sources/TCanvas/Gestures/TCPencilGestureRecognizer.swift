import UIKit

@MainActor
protocol TCPencilGestureRecognizerDelegate: AnyObject {
    func didReceiveEstimatedPencilTouches(_ touches: Set<UITouch>)
    func didReceiveActualPencilTouches(_ touches: Set<UITouch>)
}

class TCPencilGestureRecognizer: UIGestureRecognizer {
    weak var pencilGestureDelegate: TCPencilGestureRecognizerDelegate?
    
    init() {
        super.init(target: nil, action: nil)
        
        allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedPencilTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedPencilTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedPencilTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedPencilTouches(touches)
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        pencilGestureDelegate?.didReceiveActualPencilTouches(touches)
    }
}


