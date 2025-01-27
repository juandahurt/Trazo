//
//  Renderer.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

import Metal

typealias Color = (r: Float, g: Float, b: Float)

class Renderer {
    let pipelineManager: PipelineManager
    
    init() {
        pipelineManager = PipelineManager()
    }
    
    func fillTexture(
        texture: MTLTexture,
        with color: Color,
        using commandBuffer: MTLCommandBuffer
    ) {
        let colorBuffer: [Float] = [
            color.r,
            color.g,
            color.b,
            1
        ]
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineManager.fillColorPipeline)
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(colorBuffer, length: MemoryLayout<Float>.stride * 4, index: 1)
        
        
        let threadGroupLength = 8
        let threadsGroupSize = MTLSize(
            width: (texture.width) / threadGroupLength,
            height: texture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (texture.width) / threadsGroupSize.width,
            height: (texture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
    
    func drawTexture(
        texture: MTLTexture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .load
        
        // TODO: move buffers creation at the start of the app
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
        
        let vertexBuffer = Metal.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Float>.stride * vertices.count
        )
        let indexBuffer = Metal.device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineManager.drawTexturePipeline)
        encoder?.setFragmentTexture(texture, index: 3)
        encoder?.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        encoder?.setVertexBytes(
            textCoord,
            length: MemoryLayout<Float>.stride * textCoord.count,
            index: 1
        )
        encoder?
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: 6,
                indexType: .uint16,
                indexBuffer: indexBuffer!,
                indexBufferOffset: 0
            )
        encoder?.endEncoding()
    }
}
