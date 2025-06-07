import simd

// TODO: fix logic

class TCTransformer {
    /// First touch of finger A
    var initialTouchA: TCTouch?
    /// First touch of finger B
    var initialTouchB: TCTouch?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    private var baseTransform: simd_float4x4 = matrix_identity_float4x4
    private var currentTransfrom: simd_float4x4 = matrix_identity_float4x4
    
    var transform: simd_float4x4 { baseTransform * currentTransfrom }
    
    private var accAngle: Float = 0
    private var currAngle: Float = 0
    
    func initialize(withTouches touchesDict: [Int: [TCTouch]]) {
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
        usingCurrentTouches touchesDict: [Int: [TCTouch]]
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
        let scaleMatrix = simd_float4x4(scaledBy: [scale, scale, 1])
        
        let rotationMatrix = simd_float4x4(rotateZ: -deltaAngle)
        let adjustedTranslation = simd_float4x4(rotateZ: accAngle) * [
            deltaTranslation.x,
            -deltaTranslation.y,
            0,
            1
        ]
        let translationMatrix = simd_float4x4(
            translateBy: [
                adjustedTranslation.x,
                -adjustedTranslation.y,
                0
            ]
        )
        
        currentTransfrom = translationMatrix * rotationMatrix * scaleMatrix
        currAngle = -deltaAngle
    }
    
    func reset() {
        initialTouchA = nil
        initialTouchB = nil
        baseTransform *= currentTransfrom
        currentTransfrom = matrix_identity_float4x4
        accAngle += currAngle
    }
}
