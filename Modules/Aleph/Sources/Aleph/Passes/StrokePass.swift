import MetalKit
import Tartarus

class StrokePass: Pass {
    let segments: [StrokeSegment]
    
    init(segments: [StrokeSegment]) {
        self.segments = segments
    }
    
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        guard let pipelineState = PipelinesManager.pipeline(for: .stroke(.normal)) else {
            return
        }
        guard let mtlTexture = TextureManager.findTexture(
            id: ctx.document.currentLayer.texture
        )
        else { return }
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].loadAction = .load
        descriptor.colorAttachments[0].texture = mtlTexture
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        encoder.setRenderPipelineState(pipelineState)
        
        let vertices: [Float] = [
            -0.5, -0.5,
            -0.5,  0.5,
             0.5, -0.5,
             0.5,  0.5
        ]
        let (vertexBuffers, vertexOffset) = ctx.bufferAllocator.alloc(vertices)
        encoder.setVertexBuffer(vertexBuffers, offset: vertexOffset, index: 0)
        
        encoder.setVertexBytes(
            &ctx.cameraMatrix,
            length: MemoryLayout<Float4x4>.stride,
            index: 1
        )
        
        encoder.setVertexBytes(
            &ctx.projectionTransform,
            length: MemoryLayout<Float4x4>.stride,
            index: 2
        )
        
        var opacity: Float = 1
        encoder.setVertexBytes(
            &opacity,
            length: MemoryLayout<Float>.stride,
            index: 3
        )
        
        let points = segments.reduce([], { $0 + $1.points })
        let transforms = points.map {
            Float4x4(scaledBy: $0.size)
                .concatenating(Float4x4(translateByX: $0.position.x, y: $0.position.y))
        }
        let (transformsBuffer, transformsOffset) = ctx.bufferAllocator.alloc(transforms)
        encoder.setVertexBuffer(transformsBuffer, offset: transformsOffset, index: 4)

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
            index: 5
        )
        
        var color = Color.blue
        encoder.setVertexBytes(&color, length: MemoryLayout<Color>.size, index: 6)
        
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
                indexBufferOffset: indexBufferOffset,
                instanceCount: points.count
            )
        encoder.endEncoding()
    }
}
