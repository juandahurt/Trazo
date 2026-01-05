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
        var cgLocation = touch.location(in: view)
        let viewSize = Size(
            width: Float(view.bounds.width),
            height: Float(view.bounds.height)
        ) * Float(view.contentScaleFactor)
        var location = .init(
            x: Float(cgLocation.x),
            y: Float(cgLocation.y)
        ) * Float(view.contentScaleFactor)
        
//        location.x -= viewSize.width / 2
//        location.y -= viewSize.height / 2
//        location.y *= -1
        
        self.location = location
//        print(location)
        
        phase = switch (touch.phase) {
        case .began: .began
        case .moved: .moved
        case .ended: .ended
        case .cancelled: .cancelled
        default: .stationary
        }
    }
}
