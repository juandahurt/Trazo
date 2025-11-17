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
    func gestureControllerDidStartPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    )
}

class GestureController {
    enum Gesture {
        case idle
        case transform
        case panWithFinger
    }
    private var touchesMap: [Int: [Touch]] = [:]
    private var touchCount: Int { touchesMap.count }
    private var currentGesture: Gesture = .idle
    
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
        
        if touchCount == 1 {
            if let touch = touches.first, currentGesture == .idle {
                delegate?.gestureControllerDidStartPanWithFinger(self, touch: touch)
            }
            currentGesture = .panWithFinger
        }
        if touchCount == 2 {
            if currentGesture == .idle {
                delegate?.gestureControllerDidStartTransform(self, touchesMap: touchesMap)
            }
            if currentGesture == .panWithFinger {
                // send drawing cancelled
                delegate?.gestureControllerDidStartTransform(self, touchesMap: touchesMap)
            }
            if currentGesture == .transform {
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
