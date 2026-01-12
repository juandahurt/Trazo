class InputTracker {
    private(set) var touchMap: [Int: [Touch]] = [:]
    
    func store(_ touches: [Touch]) {
        for touch in touches {
            touchMap[touch.id, default: []].append(touch)
        }
    }
    
    func removeEndedTouches() {
        for key in touchMap.keys {
            if let phase = touchMap[key]?.last?.phase, phase == .cancelled || phase == .ended {
                touchMap.removeValue(forKey: key)
            }
        }
    }
}
