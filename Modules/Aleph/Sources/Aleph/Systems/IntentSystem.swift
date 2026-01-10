class IntentSystem {
    enum Gesture {
        case idle
        case transform
        case panWithFinger
    }
    private var touchMap: [Int: [Touch]] = [:]
    private var touchCount: Int { touchMap.count }
    private var currentGesture: Gesture = .idle
   
    private var userLiftedTheirFingers: Bool {
        touchMap.keys
            .reduce(
                true,
                { $0 && (touchMap[$1]?.last?.phase == .ended || touchMap[$1]?.last?.phase == .cancelled)
                })
    }
    
    func resolve(_ input: [[Touch]]) -> [InputIntent] {
        input.map {
            var intent: InputIntent = .unknown
            store(touches: $0)
            if touchCount == 2 {
                if currentGesture == .idle {
                    // when we don't have any gesture, we start a new transform
                    intent = .transform(.start, touchMap)
                }
                if currentGesture == .transform {
                    // when tranforming, we update the current tranform
                    intent = .transform(.update, touchMap)
                }
                currentGesture = .transform
            }
            if userLiftedTheirFingers {
                // when we lift the finger off the screen, we don't have any gesture
                currentGesture = .idle
            }
            removeEndedTouches()
            return intent
        }
    }
    
    private func store(touches: [Touch]) {
        for touch in touches {
            touchMap[touch.id, default: []].append(touch)
        }
    }
    
    private func removeEndedTouches() {
        for key in touchMap.keys {
            if let phase = touchMap[key]?.last?.phase, phase == .cancelled || phase == .ended {
                touchMap.removeValue(forKey: key)
            }
        }
    }
}
