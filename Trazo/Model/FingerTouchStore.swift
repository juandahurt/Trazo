//
//  FingerTouchStore.swift
//  Trazo
//
//  Created by Juan Hurtado on 19/03/25.
//


class FingerTouchStore {
    private(set) var touchesDict: [Touch.ID: [Touch]] = [:]
    
    var numberOfTouches: Int {
        touchesDict.count
    }
    
    func save(_ touches: [Touch]) {
        for touch in touches {
            let key = touch.id
            if touchesDict[key] == nil {
                // if this is a new touch, we create an empty entry
                touchesDict[key] = []
            }
            // we append the touch to its corresponding key
            touchesDict[key]?.append(touch)
        }
    }
    
    func removeTouch(byID id: Touch.ID) {
        touchesDict.removeValue(forKey: id)
    }
}
