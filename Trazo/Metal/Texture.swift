//
//  Texture.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import Metal

struct Texture {
    var actualTexture: MTLTexture
    var buffers: DrawingBuffers
    
    init(metalTexture: MTLTexture) {
        let vertices: [Float] = [
            -1, -1,
            1, -1,
            -1, 1,
             1, 1
        ]
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        
        let textCoord: [Float] = [
            0, 1,
            1, 1,
            0, 0,
            1, 0
        ]
        let textCoordSize = MemoryLayout<Float>.stride * textCoord.count
        
        let vertexBuffer = Metal.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Float>.stride * vertices.count
        )
        guard let indexBuffer = Metal.device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
        ) else {
            fatalError("index buffer could not be created.")
        }
        
        
        buffers = .init(
            vertexBuffer: vertexBuffer,
            indexBuffer: indexBuffer,
            textCoordinates: textCoord,
            textCoordSize: textCoordSize,
            numIndices: indices.count
        )
        
        actualTexture = metalTexture
    }
}

struct DrawingBuffers {
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer
    
    var textCoordinates: [Float]
    var textCoordSize: Int
    
    var numIndices: Int
}
