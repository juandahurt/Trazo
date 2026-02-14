import UIKit

class PencilGestureRecognizer: UIGestureRecognizer {
    var onTouchReceived: ((UITouch) -> Void)?
    
    init() {
        super.init(target: nil, action: nil)
       
        allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        onTouchReceived?(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        event.coalescedTouches(for: touch)?.forEach {
            onTouchReceived?($0)
        }
        onTouchReceived?(touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        onTouchReceived?(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        onTouchReceived?(touch)
    }
}
