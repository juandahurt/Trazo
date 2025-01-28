//
//  Renderer.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

import Metal

typealias Color = (r: Float, g: Float, b: Float)

final class Renderer {
    private init() {}
   
    static let instance = Renderer()
    
    func fillTexture(
        texture: Texture,
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
        encoder?.setComputePipelineState(PipelinesStore.instance.fillColorPipeline)
        encoder?.setTexture(texture.actualTexture, index: 0)
        encoder?.setBytes(colorBuffer, length: MemoryLayout<Float>.stride * 4, index: 1)
        
        
        let threadGroupLength = 8 // TODO: move this to some global scope?
        let threadsGroupSize = MTLSize(
            width: (texture.actualTexture.width) / threadGroupLength,
            height: texture.actualTexture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (texture.actualTexture.width) / threadsGroupSize.width,
            height: (texture.actualTexture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
    
    func drawTexture(
        texture: Texture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .load
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(PipelinesStore.instance.drawTexturePipeline)
        encoder?.setFragmentTexture(texture.actualTexture, index: 3)
        encoder?.setVertexBuffer(
            texture.buffers.vertexBuffer,
            offset: 0,
            index: 0
        )
        encoder?.setVertexBytes(
            texture.buffers.textCoordinates,
            length: texture.buffers.textCoordSize,
            index: 1
        )
        encoder?
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: texture.buffers.numIndices,
                indexType: .uint16,
                indexBuffer: texture.buffers.indexBuffer,
                indexBufferOffset: 0
            )
        encoder?.endEncoding()
    }
}
