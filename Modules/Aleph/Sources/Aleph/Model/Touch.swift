import Tartarus

struct Touch {
    var id: Int
    var location: Point
    var phase: Phase
    
    enum Phase {
        case began
        case moved
        case stationary
        case ended
        case cancelled
    }
}


// MARK: UIKit extensions
import UIKit

extension Touch {
    init(touch: UITouch, in view: UIView) {
        id = touch.hashValue
        let location = touch.location(in: view)
        self.location = .init(
            x: Float(location.x),
            y: Float(location.y)
        )
        phase = switch (touch.phase) {
        case .began: .began
        case .moved: .moved
        case .ended: .ended
        case .cancelled: .cancelled
        default: .stationary
        }
    }
}
