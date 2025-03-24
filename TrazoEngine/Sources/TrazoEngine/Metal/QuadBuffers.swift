//
//  QuadBuffers.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import Metal

@MainActor
struct QuadBuffers {
    static let textureBuffer: MTLBuffer = {
        let textCoord: [Float] = [
            0, 1,
            1, 1,
            0, 0,
            1, 0
        ]
        let buffer = GPU.device.makeBuffer(
            bytes: textCoord,
            length: MemoryLayout<Float>.stride * textCoord.count
        )
        assert(buffer != nil, "Texture buffer couldn't be created.")
        return buffer!
    }()
    
    static let indexBuffer: MTLBuffer = {
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        guard let indexBuffer = GPU.device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
        ) else {
            fatalError("index buffer could not be created.")
        }
        return indexBuffer
    }()
    
    static let indexCount = 6
}
