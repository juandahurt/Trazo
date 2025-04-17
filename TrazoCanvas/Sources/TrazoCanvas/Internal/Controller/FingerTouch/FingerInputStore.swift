//
//  FingerInputStore.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

struct FingerInputStore {
    private(set) var touchesDict: [TouchInput.ID: [TouchInput]] = [:]
    
    var numberOfTouches: Int {
        touchesDict.count
    }
    
    mutating func save(_ touches: [TouchInput]) {
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
    
    mutating func removeTouch(identifiedBy id: TouchInput.ID) {
        touchesDict.removeValue(forKey: id)
    }
}
