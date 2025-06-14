import Combine
import simd
import TTypes
import UIKit

@MainActor
class TCCanvasGestureController {
    enum TCFingerGestureResult {
        case draw(TTTouch)
        case transform([Int: [TTTouch]])
        case unknown
        case liftedFingers
    }
    
    var fingerGestureSubject = PassthroughSubject<TCFingerGestureResult, Never>()
    
    private(set) var touchesMap: [Int: [TTTouch]] = [:]
    
    private var numberOfTouches: Int {
        touchesMap.count
    }
    
    private var estimatedGestureType: TCGestureType {
        switch numberOfTouches {
        case 1: .drawWithFinger
        case 2: .transform
        default: .none
        }
    }
    
    private var hasUserLiftedFingers: Bool {
        touchesMap.keys
            .reduce(
                true,
                { $0 && (touchesMap[$1]?.last?.phase == .ended || touchesMap[$1]?.last?.phase == .cancelled)
                })
    }
    
    func handleFingerTouches(_ touches: [TTTouch]) {
        save(touches: touches)
        
        switch estimatedGestureType {
        case .none:
            fingerGestureSubject.send(.unknown)
        case .drawWithFinger:
            if let touch = touches.first {
                fingerGestureSubject.send(.draw(touch))
            }
        case .transform:
            fingerGestureSubject.send(.transform(touchesMap))
        }
        
        if hasUserLiftedFingers {
            fingerGestureSubject.send(.liftedFingers)
        }
        
        // check if the touches need to be removed (aka. if the gesture has finished)
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled {
                removeTouch(byId: touch.id)
            }
        }
    }
    
    private func save(touches: [TTTouch]) {
        for touch in touches {
            let key = touch.id
            if touchesMap[key] == nil {
                // if this is a new touch, we create an empty entry
                touchesMap[key] = []
            }
            // we append the touch to its corresponding key
            touchesMap[key]?.append(touch)
        }
    }
    
    private func removeTouch(byId id: Int) {
        touchesMap.removeValue(forKey: id)
    }
}
