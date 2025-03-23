//
//  Buffers.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import Metal

@MainActor
struct Buffers {
    static let texture: MTLBuffer = {
        let textCoord: [Float] = [
            0, 1,
            1, 1,
            0, 0,
            1, 0
        ]
        let buffer = Metal.device.makeBuffer(
            bytes: textCoord,
            length: MemoryLayout<Float>.stride * textCoord.count
        )
        assert(buffer != nil, "Texture buffer couldn't be created.")
        return buffer!
    }()
}
