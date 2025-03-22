//
//  Mat3x3+methods.swift
//  TrazoCore
//
//  Created by Juan Hurtado on 21/03/25.
//

import simd

public extension Mat3x3 {
    static let identity: Mat3x3 = matrix_identity_float3x3
}

public extension Mat3x3 {
    init(rotatedBy angle: Float) {
        let rows: [simd_float3] = [
            [cos(angle), -sin(angle), 0],
            [sin(angle), cos(angle),  0],
            [0,       0,              1]
        ]
        self.init(rows: rows)
    }
}
