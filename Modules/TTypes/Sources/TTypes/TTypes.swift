import simd
import UIKit

public typealias TTPoint = simd_float2

public extension TTPoint {
    func applying(_ transform: TTTransform) -> TTPoint {
        let transformedPoint = transform * [x, y, 0, 1]
        return .init(transformedPoint.x, transformedPoint.y)
    }
}

// this looks horrible
public typealias TTTransform = simd_float4x4
