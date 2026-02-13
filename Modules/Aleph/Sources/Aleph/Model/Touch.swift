import Tartarus

struct Touch {
    var id: Int
    var location: Point
    var phase: Phase
    var force: Float
    
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
    @MainActor
    init(touch: UITouch, in view: UIView) {
        id = touch.hashValue
        let cgLocation = touch.location(in: view)
        let location = .init(
            x: Float(cgLocation.x),
            y: Float(cgLocation.y)
        ) * Float(view.contentScaleFactor)
        
        self.location = location
        
        force = Float(touch.force)
        
        phase = switch (touch.phase) {
        case .began: .began
        case .moved: .moved
        case .ended: .ended
        case .cancelled: .cancelled
        default: .stationary
        }
    }
}
