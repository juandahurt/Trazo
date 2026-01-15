import MetalKit
import Tartarus

class PresentPass: RenderPass {
    func encode(
        context: SceneContext,
        commandBuffer: any MTLCommandBuffer,
        drawable: CAMetalDrawable
    ) {
        guard let pipelineState = PipelinesManager.renderPipeline(for: .drawTexture)
        else { return }
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = .init(
            red: 0.9,
            green: 0.9,
            blue: 0.9,
            alpha: 1
        )
        guard
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        encoder.setRenderPipelineState(pipelineState)
        if let texture = TextureManager.findTexture(
            id: context.renderContext.renderableTexture
        ) {
            encoder.setFragmentTexture(texture, index: 3)
            
            let vertices: [Float] = [
                0, 0,// top left
                Float(texture.width), 0, // top right
                0, Float(texture.height), // bottom left
                Float(texture.width), Float(texture.height) // bottom right
            ]
            
            // TODO: Remove buffer creation for vertex
            let vertexBuffer = GPU.device.makeBuffer(
                bytes: vertices,
                length: MemoryLayout<Float>.stride * vertices.count
            )
            
            encoder.setVertexBuffer(
                vertexBuffer,
                offset: 0,
                index: 0
            )
            
            encoder.setVertexBuffer(
                Buffer.quad.textureBuffer,
                offset: 0,
                index: 1
            )
            
            var ctm = context.renderContext.transform
            encoder.setVertexBytes(
                &ctm,
                length: MemoryLayout<Transform.Matrix>.stride,
                index: 2
            )
            var cpm = context.renderContext.projectionTransform
            encoder.setVertexBytes(
                &cpm,
                length: MemoryLayout<Transform.Matrix>.stride,
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
        }
        encoder.endEncoding()
        commandBuffer.present(drawable)
    }
}
