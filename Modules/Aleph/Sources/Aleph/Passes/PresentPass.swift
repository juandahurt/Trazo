import MetalKit
import Tartarus

class PresentPass: Pass {
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        guard let pipelineState = PipelinesManager.pipeline(for: .present)
        else { return }
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = ctx.clearColor.mtlClearColor
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].texture = drawable.texture
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        guard let texture = TextureManager.findTexture(id: ctx.canvasTexture)
        else { return }
        
        encoder.setRenderPipelineState(pipelineState)
        
        // MARK: Vertex buffer
        let vertices: [Float] = [
            0, 0,// top left
            Float(texture.width), 0, // top right
            0, Float(texture.height), // bottom left
            Float(texture.width), Float(texture.height) // bottom right
        ]
        let (vertexBuffer, vertexOffset) = ctx.bufferAllocator.alloc(vertices)
        encoder.setVertexBuffer(vertexBuffer, offset: vertexOffset, index: 0)
        
        // MARK: Texture buffer
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
        
        // MARK: Camera matrix
        encoder.setVertexBytes(
            &ctx.cameraMatrix,
            length: MemoryLayout<Float4x4>.stride,
            index: 2
        )
        
        // MARK: Projection matrix
        encoder.setVertexBytes(
            &ctx.projectionTransform,
            length: MemoryLayout<Float4x4.Matrix>.stride,
            index: 3
        )
      
        // MARK: Canvas texture
        encoder.setFragmentTexture(texture, index: 3)
        
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        let (indexBuffer, indexBufferOffset) = ctx.bufferAllocator.alloc(indices)
        encoder
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: indices.count,
                indexType: .uint16,
                indexBuffer: indexBuffer,
                indexBufferOffset: indexBufferOffset
            )
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
    }
}
