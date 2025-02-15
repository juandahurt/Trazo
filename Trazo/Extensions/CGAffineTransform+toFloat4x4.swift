//
//  CGAffineTransform+toFloat4x4.swift
//  Trazo
//
//  Created by Juan Hurtado on 15/02/25.
//

import CoreGraphics
import simd

extension CGAffineTransform {
    func toFloat4x4() -> float4x4 {
        float4x4([
            [Float(a), Float(b), 0, 0],
            [Float(c), Float(d), 0, 0],
            [0, 0, 1, 0],
            [Float(tx), Float(ty), 1, 1]
        ])
    }
}
