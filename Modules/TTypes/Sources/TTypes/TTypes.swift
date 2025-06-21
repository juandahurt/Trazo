import simd
import UIKit

public struct TTTouch {
    public let id: Int
    public let location: TTPoint
    public let phase: UITouch.Phase
    
    public init(id: Int, location: simd_float2, phase: UITouch.Phase) {
        self.id = id
        self.location = location
        self.phase = phase
    }
}

public typealias TTPoint = simd_float2

public extension TTPoint {
    func applying(_ transform: TTTransform) -> TTPoint {
        let transformedPoint = transform * [x, y, 0, 1]
        return .init(transformedPoint.x, transformedPoint.y)
    }
}

// this looks horrible
public typealias TTTransform = simd_float4x4
