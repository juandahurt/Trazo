import Foundation
import Tartarus

class TransformSystem {
    /// First touch of finger A
    var initialTouchA: Touch?
    /// First touch of finger B
    var initialTouchB: Touch?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    func reset(ctx: inout SceneContext, touchMap: [Int: [Touch]]) {
        guard
            let keyA = touchMap.keys.sorted().first,
            let keyB = touchMap.keys.sorted().last,
            let touchA = touchMap[keyA]?.first, // since we have only one touch in the array
            let touchB = touchMap[keyB]?.first  // we select the first and only element
        else {
            fatalError("failed to reset transform system")
        }
        ctx.renderContext.baseTransform = ctx.renderContext.currentTransform.concatenating(ctx.renderContext.baseTransform)
        ctx.renderContext.currentTransform = .identity
        
        initialTouchA = touchA
        initialTouchB = touchB
    }
    
    func update(ctx: inout SceneContext, touchMap: [Int: [Touch]]) {
        guard touchMap.count == 2 else { return }
        guard
            let initialTouchA,
            let initialTouchB,
            let lastTouchA = touchMap[initialTouchA.id]?.last,
            let lastTouchB = touchMap[initialTouchB.id]?.last
        else {
            return
        }
        
        let inverse = ctx.renderContext.baseTransform.inverse
        let initialPointA = initialTouchA.location.applying(inverse)
        let currentPointA = lastTouchA.location.applying(inverse)
        let initialPointB = initialTouchB.location.applying(inverse)
        let currentPointB = lastTouchB.location.applying(inverse)
        
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
        let rotationMatrix = Transform(rotatedBy: Float(-deltaAngle))
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
        
        ctx.renderContext.currentTransform = translationMatrix.concatenating(pivotTransform)
    }
}

