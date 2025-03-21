//
//  CanvasTransformer.swift
//  Trazo
//
//  Created by Juan Hurtado on 18/03/25.
//

import CoreGraphics
import TrazoCore

class CanvasTransformer {
    /// First touch of finger A
    var initialTouchA: Touch?
    /// First touch of finger B
    var initialTouchB: Touch?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    /// Current transformation matrix
    var ctm: CGAffineTransform = .identity
    private var ltm: CGAffineTransform = .identity
    
    func initialize(withTouches touchesDict: [Touch.ID: [Touch]]) {
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
    
    func tranform(
        usingCurrentTouches touchesDict: [Touch.ID: [Touch]],
        canvasCenter center: vector_t
    ) -> CGAffineTransform? {
        // logic found at: https://mortoray.com/a-pan-zoom-and-rotate-gesture-model-for-touch-devices/
        guard
            let initialTouchA,
            let initialTouchB,
            let lastTouchA = touchesDict[initialTouchA.id]?.last,
            let lastTouchB = touchesDict[initialTouchB.id]?.last
        else {
            return nil
        }
        
        let initialPointA = initialTouchA.location
        let currentPointA = lastTouchA.location
        let initialPointB = initialTouchB.location
        let currentPointB = lastTouchB.location
        
        // translation
        let startCenter = (initialPointA - initialPointB) / 2 + initialPointB
        let currentCenter = (currentPointA - currentPointB) / 2 + currentPointB
        
        let translationVector = currentCenter - startCenter
        let rawTranslation = CGPoint(
            x: CGFloat(translationVector.x),
            y: CGFloat(translationVector.y)
        )
        
        // rotation
        let startVector = initialPointA - initialPointB
        let currentVector = currentPointA - currentPointB
        
        let startAngle = atan2(startVector.y, startVector.x)
        let endAngle = atan2(currentVector.y, currentVector.x)
        
        let deltaAngle = endAngle - startAngle
        
        let rotationMatrix = CGAffineTransform(rotationAngle: -CGFloat(deltaAngle))
       
        // zooming
        let scale = currentVector.length() / startVector.length()
        
        let scaleMatrix = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        
        let translation = rawTranslation.applying(rotationMatrix) / CGFloat(scale)
        
        let translationMatrix = CGAffineTransform(
            translationX: translation.x,
            y: -translation.y
        )
        let matrix = translationMatrix.concatenating(rotationMatrix).concatenating(
            scaleMatrix
        )
        
        ltm = ctm.concatenating(matrix)
        return ctm.concatenating(matrix)
    }
    
    func reset() {
        initialTouchA = nil
        initialTouchB = nil
        ctm = ltm
    }
}
