import TTypes
import UIKit

struct TCTouch {
    public let id: Int
    public let location: TTPoint
    public let phase: UITouch.Phase
    public let estimationUpdateIndex: NSNumber?
    
    @MainActor
    init(_ uiTouch: UITouch, view: UIView) {
        self.id = Int(uiTouch.hashValue)
        self.location = .init(uiTouch.location(fromCenterOfView: view))
        self.phase = uiTouch.phase
        self.estimationUpdateIndex = uiTouch.estimationUpdateIndex
    }
}

