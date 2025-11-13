import UIKit

protocol GestureControllerDelegate: AnyObject {
    func gestureControllerDidStartTransform(
        _ controller: GestureController,
        touchesMap: [Int: [Touch]]
    )
    func gestureControllerDidTransform(
        _ controller: GestureController,
        touchesMap: [Int: [Touch]]
    )
}

class GestureController {
    enum Gesture {
        case idle
        case transform
    }
    private var touchesMap: [Int: [Touch]] = [:]
    private var touchCount: Int { touchesMap.count }
    private var currentGesture: Gesture = .idle {
        didSet {
            print(currentGesture)
        }
    }
    
    weak var delegate: GestureControllerDelegate?
    
    private var userLiftedTheirFingers: Bool {
        touchesMap.keys
            .reduce(
                true,
                { $0 && (touchesMap[$1]?.last?.phase == .ended || touchesMap[$1]?.last?.phase == .cancelled)
                })
    }
    
    func handleFingerTouches(_ touches: [Touch]) {
        store(touches: touches)
        
        if touchCount == 2 {
            if currentGesture == .idle {
                delegate?.gestureControllerDidStartTransform(self, touchesMap: touchesMap)
            } else {
                delegate?.gestureControllerDidTransform(self, touchesMap: touchesMap)
            }
            currentGesture = .transform
        }
        
        if userLiftedTheirFingers {
            currentGesture = .idle
        }
        
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
