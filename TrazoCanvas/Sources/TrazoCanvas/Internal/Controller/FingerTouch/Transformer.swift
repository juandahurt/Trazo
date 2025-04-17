//
//  Transformer.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import Foundation
import TrazoCore
import simd

class Transformer {
    /// First touch of finger A
    var initialTouchA: TouchInput?
    /// First touch of finger B
    var initialTouchB: TouchInput?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    private var baseTransform: Mat4x4 = .identity
    private var currentTransfrom: Mat4x4 = .identity
    
    var transform: Mat4x4 { baseTransform * currentTransfrom }
    
    private var accAngle: Float = 0
    private var currAngle: Float = 0
    
    func initialize(withTouches touchesDict: [TouchInput.ID: [TouchInput]]) {
        guard
            let keyA = touchesDict.keys.sorted().first,
            let keyB = touchesDict.keys.sorted().last,
            let touchA = touchesDict[keyA]?.first, // since we have only one touch in the array
            let touchB = touchesDict[keyB]?.first  // we select the first and only element
        else {
            fatalError("failed to initialize transformer")
        }
        initialTouchA = touchA
        initialTouchB = touchB
    }
    
    func transform(
        usingCurrentTouches touchesDict: [TouchInput.ID: [TouchInput]]
    ) {
        // logic found at: https://mortoray.com/a-pan-zoom-and-rotate-gesture-model-for-touch-devices/
        guard
            let initialTouchA,
            let initialTouchB,
            let lastTouchA = touchesDict[initialTouchA.id]?.last,
            let lastTouchB = touchesDict[initialTouchB.id]?.last
        else {
            return
        }
        
        let initialPointA = initialTouchA.location
        let currentPointA = lastTouchA.location
        let initialPointB = initialTouchB.location
        let currentPointB = lastTouchB.location
        
        // translation
        let startCenter = (initialPointA - initialPointB) / 2 + initialPointB
        let currentCenter = (currentPointA - currentPointB) / 2 + currentPointB
        let deltaTranslation = currentCenter - startCenter
        
        // rotation
        let startVector = initialPointA - initialPointB
        let currentVector = currentPointA - currentPointB
        let startAngle = atan2(startVector.y, startVector.x)
        let endAngle = atan2(currentVector.y, currentVector.x)
        let deltaAngle = endAngle - startAngle

        // zooming
        let scale = length(currentVector) / length(startVector)
        
        // matrices
        let scaleMatrix = Mat4x4(scaledBy: [scale, scale, 1])
        
        let rotationMatrix = Mat4x4(rotateZ: deltaAngle)
        let adjustedTranslation = Mat4x4(rotateZ: accAngle) * [
            deltaTranslation.x,
            deltaTranslation.y,
            0,
            1
        ]
        let translationMatrix = Mat4x4(
            translateBy: [
                adjustedTranslation.x,
                -adjustedTranslation.y,
                0
            ]
        )
        
        currentTransfrom = translationMatrix * rotationMatrix * scaleMatrix
        currAngle = deltaAngle
    }
    
    func reset() {
        initialTouchA = nil
        initialTouchB = nil
        baseTransform *= currentTransfrom
        currentTransfrom = .identity
        accAngle += currAngle
    }
}
