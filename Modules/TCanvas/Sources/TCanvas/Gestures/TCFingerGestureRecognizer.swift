import UIKit

@MainActor
protocol TCFingerGestureRecognizerDelegate: AnyObject {
    func didReceiveFingerTouches(_ touches: Set<UITouch>)
}

class TCFingerGestureRecognizer: UIGestureRecognizer {
    weak var fingerGestureDelegate: TCFingerGestureRecognizerDelegate?
    
    init() {
        super.init(target: nil, action: nil)
        
        allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
}

