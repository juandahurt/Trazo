import MetalKit
import Tartarus

class PresentPass: Pass {
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        guard let pipelineState = PipelinesManager.renderPipeline(for: .present)
        else { return }
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = .init(
            red: ctx.clearColor.r,
            green: ctx.clearColor.g,
            blue: ctx.clearColor.b,
            alpha: ctx.clearColor.a
        )
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
        let (vertexBuffer, offset) = ctx.frameAllocator.alloc(vertices)
        encoder.setVertexBuffer(vertexBuffer, offset: offset, index: 0)
        
        // MARK: Texture buffer
        encoder.setVertexBuffer(
            Buffer.quad.textureBuffer,
            offset: 0,
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
        
        encoder
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: Buffer.quad.indexCount,
                indexType: .uint16,
                indexBuffer: Buffer.quad.indexBuffer,
                indexBufferOffset: 0
            )
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
    }
}
