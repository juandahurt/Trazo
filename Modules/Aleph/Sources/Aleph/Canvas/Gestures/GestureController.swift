import UIKit

protocol GestureControllerDelegate: AnyObject {
    func gestureControllerDidStartTransform(_ controller: GestureController)
}

enum Gesture {
    case transform
}

class GestureController {
    private var touchesMap: [Int: [Touch]] = [:]
    
    private var touchCount: Int { touchesMap.count }
    
    func handleFingerTouches(_ touches: [Touch]) {
        store(touches: touches)
        
        print(touchesMap.count)
        
        removeEndedTouches()
    }
    
    private func store(touches: [Touch]) {
        for touch in touches {
            touchesMap[touch.id, default: []].append(touch)
        }
    }
    
    private func removeEndedTouches() {
        for key in touchesMap.keys {
            if let phase = touchesMap[key]?.last?.phase, phase == .cancelled || phase == .ended {
                touchesMap.removeValue(forKey: key)
            }
        }
    }
}
