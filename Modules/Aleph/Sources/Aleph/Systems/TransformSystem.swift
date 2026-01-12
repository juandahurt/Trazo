import Foundation
import Tartarus

class TransformSystem {
    func update(ctx: inout SceneContext, intent: InputIntent) {
        guard case let .transform(phase, data) = intent else { return }
        switch phase {
        case .update:
            guard let data else { return }
            let inverse = ctx.renderContext.baseTransform.inverse
            let initialPointA = data.startPointA.applying(inverse)
            let currentPointA = data.currPointA.applying(inverse)
            let initialPointB = data.startPointB.applying(inverse)
            let currentPointB = data.currPointB.applying(inverse)
            
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
        case .ended:
            ctx.renderContext.baseTransform = ctx.renderContext.currentTransform.concatenating(ctx.renderContext.baseTransform)
            ctx.renderContext.currentTransform = .identity
        default: break
        }
    }
}

