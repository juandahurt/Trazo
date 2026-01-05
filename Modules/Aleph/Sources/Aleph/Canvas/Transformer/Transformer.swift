import Foundation
import Tartarus

class Transformer {
    /// First touch of finger A
    var initialTouchA: Touch?
    /// First touch of finger B
    var initialTouchB: Touch?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    private var baseTransform = Transform.identity
    private var currentTransform = Transform.identity
    
    var transform: Transform { currentTransform.concatenating(baseTransform) }
    
    func initialize(withTouches touchesDict: [Int: [Touch]]) {
        guard
            let keyA = touchesDict.keys.sorted().first,
            let keyB = touchesDict.keys.sorted().last,
            let touchA = touchesDict[keyA]?.first, // since we have only one touch in the array
            let touchB = touchesDict[keyB]?.first  // we select the first and only element
        else {
            fatalError("failed to initialize transformer")
        }
        reset()
        initialTouchA = touchA
        initialTouchB = touchB
    }
    
    func transform(currentTouches: [Int: [Touch]]) {
        guard
            let initialTouchA,
            let initialTouchB,
            let lastTouchA = currentTouches[initialTouchA.id]?.last,
            let lastTouchB = currentTouches[initialTouchB.id]?.last
        else {
            return
        }
        
        let initialPointA = initialTouchA.location.applying(baseTransform.inverse)
        let currentPointA = lastTouchA.location.applying(baseTransform.inverse)
        let initialPointB = initialTouchB.location.applying(baseTransform.inverse)
        let currentPointB = lastTouchB.location.applying(baseTransform.inverse)
        
        // midpoint displacement
        let startCenter = (initialPointA - initialPointB) / 2 + initialPointB
        let currentCenter = (currentPointA - currentPointB) / 2 + currentPointB
        let deltaTranslation = currentCenter - startCenter

        let startVector = initialPointA - initialPointB
        let currentVector = currentPointA - currentPointB
        let startAngle = atan2f(startVector.y, startVector.x)
        let endAngle = atan2f(currentVector.y, currentVector.x)
        let deltaAngle = endAngle - startAngle
        
        let scale = currentVector.length() / startVector.length()

        let pivotPoint = Point(x: currentCenter.x, y: currentCenter.y)
        let translateToOrigin = Transform(translateByX: -pivotPoint.x, y: -pivotPoint.y)
        let scaleMatrix = Transform(scaledBy: scale)
        let rotationMatrix = Transform(rotatedBy: -deltaAngle)
        let translateBack = Transform(translateByX: pivotPoint.x, y: pivotPoint.y)
        let pivotTransform = Transform.identity
            .concatenating(translateToOrigin)
            .concatenating(scaleMatrix)
            .concatenating(rotationMatrix)
            .concatenating(translateBack)

        let translationMatrix = Transform(
            translateByX: deltaTranslation.x,
            y: deltaTranslation.y
        )
        
        currentTransform = translationMatrix.concatenating(pivotTransform)
    }
    
    func reset() {
        initialTouchA = nil
        initialTouchB = nil
        baseTransform = currentTransform.concatenating(baseTransform)
        currentTransform = .identity
    }
}
