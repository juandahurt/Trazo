import simd

public struct Float4x4 {
    public typealias Matrix = simd_float4x4
    var matrix: Matrix
    
    public var inverse: Float4x4 {
        return .init(matrix: matrix.inverse)
    }
    
    public var scale: Float {
        length(simd_float2([matrix.columns.0.x, matrix.columns.0.y]))
    }
}

// MARK: - Multiplication
public extension Float4x4 {
    func concatenating(_ other: Float4x4) -> Float4x4 {
        Float4x4(matrix: other.matrix * matrix)
    }
}

// MARK: - Useful initializers
public extension Float4x4 {
    init(ortho rect: Rect, near: Float, far: Float) {
        let left = rect.x
        let right = rect.x + rect.width
        let top = rect.y
        let bottom = rect.y + rect.height
        let X = simd_float4(2 / (right - left), 0, 0, 0)
        let Y = simd_float4(0, 2 / (top - bottom), 0, 0)
        let Z = simd_float4(0, 0, 1 / (far - near), 0)
        let W = simd_float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1)
        matrix = .init(columns: (X, Y, Z, W))
    }
    
    public init(rotatedBy angle: Float) {
        let rows: [simd_float4] = [
            [ cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        ]
        self.init(matrix: .init(rows: rows))
    }
    
    public init(scaledBy value: Float) {
        self.init(scaledByX: value, y: value)
    }
   
    public init(scaledByX x: Float, y: Float) {
        let rows: [simd_float4] = [
            [x,         0,         0, 0],
            [      0,   y,         0, 0],
            [      0,       0,         1, 0],
            [      0,       0,         0, 1]
        ]
        self.init(matrix: .init(rows: rows))
    }
    
    public init(translateByX x: Float, y: Float) {
        let rows: [simd_float4] = [
            [1, 0, 0, x],
            [0, 1, 0, y],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ]
        self.init(matrix: .init(rows: rows))
    }
}

// MARK: - Static properties
public extension Float4x4 {
    nonisolated(unsafe)
    static let identity = Float4x4(matrix: matrix_identity_float4x4)
}
// MARK: - CoreGraphics
import CoreGraphics

public extension Float4x4 {
    func affineTransform() -> CGAffineTransform {
        .init(
            a:  CGFloat(matrix.columns.0.x),
            b:  CGFloat(matrix.columns.0.y),
            c:  CGFloat(matrix.columns.1.x),
            d:  CGFloat(matrix.columns.1.y),
            tx: CGFloat(matrix.columns.3.x),
            ty: CGFloat(matrix.columns.3.y)
        )
    }
}

import QuartzCore

public extension Float4x4 {
    func caTransform3d() -> CATransform3D {
        CATransform3D(
                m11: CGFloat(matrix.columns.0.x), m12: CGFloat(matrix.columns.0.y), m13: CGFloat(matrix.columns.0.z), m14: CGFloat(matrix.columns.0.w),
                m21: CGFloat(matrix.columns.1.x), m22: CGFloat(matrix.columns.1.y), m23: CGFloat(matrix.columns.1.z), m24: CGFloat(matrix.columns.1.w),
                m31: CGFloat(matrix.columns.2.x), m32: CGFloat(matrix.columns.2.y), m33: CGFloat(matrix.columns.2.z), m34: CGFloat(matrix.columns.2.w),
                m41: CGFloat(matrix.columns.3.x), m42: CGFloat(matrix.columns.3.y), m43: CGFloat(matrix.columns.3.z), m44: CGFloat(matrix.columns.3.w)
            )
    }
}
