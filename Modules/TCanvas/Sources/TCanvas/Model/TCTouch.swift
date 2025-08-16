import TTypes
import UIKit

struct TCTouch {
    let id: Int
    let location: TTPoint
    let phase: UITouch.Phase
    let estimationUpdateIndex: NSNumber?
    let force: Float
    
    @MainActor
    init(_ uiTouch: UITouch, view: UIView) {
        self.id = Int(uiTouch.hashValue)
        self.location = .init(uiTouch.location(fromCenterOfView: view))
        self.phase = uiTouch.phase
        self.estimationUpdateIndex = uiTouch.estimationUpdateIndex
        self.force = uiTouch.type == .direct ? 1 : Float(uiTouch.force)
    }
}

