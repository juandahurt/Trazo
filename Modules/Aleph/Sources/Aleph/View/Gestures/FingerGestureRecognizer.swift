import UIKit

class FingerGestureRecognizer: UIPanGestureRecognizer {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
       
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
        allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
    }
}
