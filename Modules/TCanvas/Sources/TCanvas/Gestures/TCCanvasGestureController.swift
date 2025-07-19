import Combine
import simd
import TTypes
import UIKit


class TCCanvasGestureController {
    enum TCFingerGestureEvent: CustomDebugStringConvertible {
        case idle
        case draw(TCTouch), drawCanceled, drawEnded
        case transform([Int: [TCTouch]]), transformInit([Int: [TCTouch]])
        
        var debugDescription: String {
            switch self {
            case .idle: "idle"
            case .draw(_): "draw"
            case .drawCanceled: "drawCanceled"
            case .drawEnded:"drawEnded"
            case .transform(_): "transform"
            case .transformInit(_): "transform init"
            }
        }
    }
    
    enum TCGesture {
        case idle
        case draw
        case unsupported
        case transform
    }
    
    var gestureEventSubject = PassthroughSubject<TCFingerGestureEvent, Never>()
    
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
    
    func handleFingerTouches(_ touches: [TCTouch]) {
        save(touches: touches)
        
        if numberOfTouches == 1 && (currentGesture == .idle || currentGesture == .draw) {
            // we can only notify the drawing event if we are currently idle
            // or already drawing
            if let touch = touches.first {
                gestureEventSubject.send(.draw(touch))
                currentGesture = .draw
            }
        }
        
        if numberOfTouches == 2 && (
            currentGesture == .idle || currentGesture == .transform || currentGesture == .draw
        ) {
            if currentGesture == .idle {
                gestureEventSubject.send(.transformInit(touchesMap))
            }
            if currentGesture == .transform {
                gestureEventSubject.send(.transform(touchesMap))
            }
            if currentGesture == .draw {
                gestureEventSubject.send(.drawCanceled)
                gestureEventSubject.send(.transformInit(touchesMap))
            }
            currentGesture = .transform
        }
        
        if numberOfTouches > 2 {
            if currentGesture == .draw {
                gestureEventSubject.send(.drawEnded)
            }
            currentGesture = .unsupported
        }

        if userLiftedTheirFingers {
            if currentGesture == .draw {
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
