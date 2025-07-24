import Combine
import simd
import TTypes
import UIKit


class TCCanvasGestureController {
    enum TCGestureEvent {
        case idle
        case fingerDraw(TCTouch), fingerDrawCanceled, drawEnded
        case pencilDraw(TCTouch)
        case transform([Int: [TCTouch]]), transformInit([Int: [TCTouch]])
    }
    
    enum TCGesture {
        case idle
        case fingerDraw
        case pencilDraw
        case unsupported
        case transform
    }
    
    var gestureEventSubject = PassthroughSubject<TCGestureEvent, Never>()
    
    private(set) var touchesMap: [Int: [TCTouch]] = [:]
    
    private var numberOfTouches: Int {
        touchesMap.count
    }
    
    private var currentGesture = TCGesture.idle
    
    private var userLiftedTheirFingers: Bool {
        touchesMap.keys
            .reduce(
                true,
                { $0 && (touchesMap[$1]?.last?.phase == .ended || touchesMap[$1]?.last?.phase == .cancelled)
                })
    }
    
    func handlePencilTouch(_ touch: TCTouch) {
        if currentGesture == .fingerDraw {
            gestureEventSubject.send(.fingerDrawCanceled)
        }
        if touch.phase == .ended || touch.phase == .cancelled {
            gestureEventSubject.send(.drawEnded)
            currentGesture = .idle
        } else {
            currentGesture = .pencilDraw
        }
        
        gestureEventSubject.send(.pencilDraw(touch))
    }
    
    func handleFingerTouches(_ touches: [TCTouch]) {
        save(touches: touches)
        
        if numberOfTouches == 1 && (currentGesture == .idle || currentGesture == .fingerDraw) {
            // we can only notify the drawing event if we are currently idle
            // or already drawing
            if let touch = touches.first {
                gestureEventSubject.send(.fingerDraw(touch))
                currentGesture = .fingerDraw
            }
        }
        
        if numberOfTouches == 2 && (
            currentGesture == .idle || currentGesture == .transform || currentGesture == .fingerDraw
        ) {
            if currentGesture == .idle {
                gestureEventSubject.send(.transformInit(touchesMap))
            }
            if currentGesture == .transform {
                gestureEventSubject.send(.transform(touchesMap))
            }
            if currentGesture == .fingerDraw {
                gestureEventSubject.send(.fingerDrawCanceled)
                gestureEventSubject.send(.transformInit(touchesMap))
            }
            currentGesture = .transform
        }
        
        if numberOfTouches > 2 {
            if currentGesture == .fingerDraw {
                gestureEventSubject.send(.drawEnded)
            }
            currentGesture = .unsupported
        }

        if userLiftedTheirFingers {
            if currentGesture == .fingerDraw {
                gestureEventSubject.send(.drawEnded)
            }
            currentGesture = .idle
        }
        
        removeEnded(touches: touches)
    }
    
    private func removeEnded(touches: [TCTouch]) {
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled {
                removeTouch(byId: touch.id)
            }
        }
    }
    
    private func save(touches: [TCTouch]) {
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
