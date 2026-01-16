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
    init(gesture: UIPanGestureRecognizer, in view: UIView) {
        id = gesture.hashValue
        var cgLocation = gesture.location(in: view)
        let viewSize = Size(
            width: Float(view.bounds.width),
            height: Float(view.bounds.height)
        ) * Float(view.contentScaleFactor)
        var location = .init(
            x: Float(cgLocation.x),
            y: Float(cgLocation.y)
        ) * Float(view.contentScaleFactor)
        
        self.location = location
        
        phase = switch (gesture.state) {
        case .began: .began
        case .changed: .moved
        case .ended: .ended
        case .cancelled: .cancelled
        default: .stationary
        }
    }
}
