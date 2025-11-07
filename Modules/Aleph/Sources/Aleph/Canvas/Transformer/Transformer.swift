import simd

class Transformer {
    /// First touch of finger A
    var initialTouchA: Touch?
    /// First touch of finger B
    var initialTouchB: Touch?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    private var baseTransform = matrix_identity_float4x4
    private var currentTransform = matrix_identity_float4x4
    
    var transform: simd_float4x4 { baseTransform * currentTransform }
    
    func initialize(withTouches touchesDict: [Int: [Touch]]) {
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
        usingCurrentTouches touchesDict: [Int: [Touch]]
    ) {
        guard
            let initialTouchA,
            let initialTouchB,
            let lastTouchA = touchesDict[initialTouchA.id]?.last,
            let lastTouchB = touchesDict[initialTouchB.id]?.last
        else {
            return
        }
        
//        let initialPointA = initialTouchA.location.applying(baseTransform.inverse)
//        let currentPointA = lastTouchA.location.applying(baseTransform.inverse)
//        let initialPointB = initialTouchB.location.applying(baseTransform.inverse)
//        let currentPointB = lastTouchB.location.applying(baseTransform.inverse)
//        
//        // midpoint displacement
//        let startCenter = (initialPointA - initialPointB) / 2 + initialPointB
//        let currentCenter = (currentPointA - currentPointB) / 2 + currentPointB
//        let deltaTranslation = currentCenter - startCenter
//        
//        let startVector = initialPointA - initialPointB
//        let currentVector = currentPointA - currentPointB
//        let startAngle = atan2(startVector.y, startVector.x)
//        let endAngle = atan2(currentVector.y, currentVector.x)
//        let deltaAngle = endAngle - startAngle
//        
//        let scale = length(currentVector) / length(startVector)
//
//        let pivotPoint = SIMD3<Float>(currentCenter.x, currentCenter.y, 0)
//        let translateToOrigin = simd_float4x4(translateBy: [-pivotPoint.x, -pivotPoint.y, 0])
//        let scaleMatrix = simd_float4x4(scaledBy: [scale, scale, 1])
//        let rotationMatrix = simd_float4x4(rotateZ: -deltaAngle)
//        let translateBack = simd_float4x4(translateBy: [pivotPoint.x, pivotPoint.y, 0])
//        let pivotTransform = translateBack * rotationMatrix * scaleMatrix * translateToOrigin
//
//        let translationMatrix = simd_float4x4(
//            translateBy: [deltaTranslation.x, deltaTranslation.y, 0]
//        )
//        
//        currentTransform = pivotTransform * translationMatrix
    }
    
    func reset() {
        initialTouchA = nil
        initialTouchB = nil
        baseTransform *= currentTransform
        currentTransform = matrix_identity_float4x4
    }
}
