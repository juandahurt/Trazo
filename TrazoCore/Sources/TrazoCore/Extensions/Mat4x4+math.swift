//
//  Mat4x4+math.swift
//  TrazoCore
//
//  Created by Juan Hurtado on 24/03/25.
//

import Foundation
import simd

public extension Mat4x4 {
    init(rotateZ angle: Float) {
        let rows: [Vector4] = [
            [ cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        ]
        self.init(rows: rows)
    }
   
    init(scaledBy value: Vector3) {
        let rows: [Vector4] = [
            [value.x,         0,         0, 0],
            [        0, value.y,         0, 0],
            [        0,       0,   value.z, 0],
            [        0,       0,         0, 1]
        ]
        self.init(rows: rows)
    }
    
    init(orthographic rect: CGRect, near: Float, far: Float) {
        let left = Float(rect.origin.x)
        let right = Float(rect.origin.x + rect.width)
        let top = Float(rect.origin.y)
        let bottom = Float(rect.origin.y - rect.height)
        let X = simd_float4(2 / (right - left), 0, 0, 0)
        let Y = simd_float4(0, 2 / (top - bottom), 0, 0)
        let Z = simd_float4(0, 0, 1 / (far - near), 0)
        let W = simd_float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    static let identity = matrix_identity_float4x4
}
