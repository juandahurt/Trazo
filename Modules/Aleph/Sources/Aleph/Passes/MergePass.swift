import MetalKit
import Tartarus

class MergePass: Pass {
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        print("merge")
        commandBuffer.pushDebugGroup("Merge")
        guard let canvasTexture = TextureManager.findTexture(id: ctx.canvasTexture) else { return }
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = canvasTexture
        descriptor.colorAttachments[0].loadAction = .load
        descriptor.colorAttachments[0].storeAction = .store
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        // MARK: Vertices buffer
        let vertices: [Float] = [
            0, 0,// top left
            Float(canvasTexture.width), 0, // top right
            0, Float(canvasTexture.height), // bottom left
            Float(canvasTexture.width), Float(canvasTexture.height) // bottom right
        ]
        let (vertexBuffer, vertexOffset) = ctx.bufferAllocator.alloc(vertices)
        encoder.setVertexBuffer(vertexBuffer, offset: vertexOffset, index: 0)
        
        // MARK: Texture coords buffer
        let textCoord: [Float] = [
            0, 0,
            1, 0,
            0, 1,
            1, 1
        ]
        let (textureBuffer, textureOffset) = ctx.bufferAllocator.alloc(textCoord)
        encoder.setVertexBuffer(
            textureBuffer,
            offset: textureOffset,
            index: 1
        )
        
        // MARK: Indices
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        let (indexBuffer, indexBufferOffset) = ctx.bufferAllocator.alloc(indices)
       
        // MARK: Projection matrix
        encoder.setVertexBytes(
            &ctx.projectionTransform,
            length: MemoryLayout<Float4x4.Matrix>.stride,
            index: 2
        )
        
        // MARK: Merge loop
        for index in 0..<ctx.document.layers.count {
            // TODO: use layer's blend mode
            guard let pipelineState = PipelinesManager.pipeline(for: .merge(.normal))
            else { return }
            encoder.setRenderPipelineState(pipelineState)
            
            guard let layerTexture = TextureManager.findTexture(
                id: ctx.document.layers[index].texture
            ) else { return }
            
            encoder.setFragmentTexture(layerTexture, index: 0)
            
            encoder
                .drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: indices.count,
                    indexType: .uint16,
                    indexBuffer: indexBuffer,
                    indexBufferOffset: indexBufferOffset
                )
        }
        
        encoder.endEncoding()
        commandBuffer.popDebugGroup()
    }
}
