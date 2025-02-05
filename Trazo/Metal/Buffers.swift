//
//  Buffers.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

struct Buffers {
    static func texture(scaledBy scale: Float) -> [Float] {
        [
            -1 * scale, -1 * scale,
             1 * scale, -1 * scale,
             -1 * scale, 1 * scale,
             1 * scale, 1 * scale
        ]
    }
}
