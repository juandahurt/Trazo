import MetalKit
import Tartarus

class StrokePass: RenderPass {
    let segment: StrokeSegment
    
    init(segment: StrokeSegment) {
        self.segment = segment
    }
    
    func encode(
        context: SceneContext,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        guard let pipelineState = PipelinesManager.renderPipeline(
            for: .drawGrayscalePoints
        ) else { return }
        guard let strokeTexture = TextureManager.findTexture(
            id: context.renderContext.strokeTexture
        ) else { return }
        
        guard !segment.points.isEmpty else { return }
        let points: [DrawablePoint] = segment.points
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].loadAction = .load
        descriptor.colorAttachments[0].texture = strokeTexture
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
       
        encoder.setRenderPipelineState(pipelineState)
        let buffer = Buffer.quad.vertexBuffer
        let tranforms: [Transform] = points.map {
            Transform.identity
                .concatenating(.init(rotatedBy: $0.angle))
                .concatenating(.init(scaledBy: $0.size * context.renderContext.transform.scale))
                .concatenating(.init(translateByX: $0.position.x,y: $0.position.y))
        }
        let transformsBuffer = GPU.device
            .makeBuffer(
                bytes: tranforms,
                length: MemoryLayout<Transform>.stride * tranforms.count
            )
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        var camera = context.renderContext.transform.inverse
        encoder.setVertexBytes(
            &camera,
            length: MemoryLayout<Transform.Matrix>.stride,
            index: 1
        )
        var projection = context.renderContext.projectionTransform
        encoder.setVertexBytes(
            &projection,
            length: MemoryLayout<Transform.Matrix>.stride,
            index: 2
        )
        var opacity = context.strokeContext.brush.opacity
        encoder.setVertexBytes(
            &opacity,
            length: MemoryLayout<Float>.stride,
            index: 3
        )
        encoder.setVertexBuffer(
            transformsBuffer,
            offset: 0,
            index: 4
        )
        encoder.setVertexBuffer(
            Buffer.quad.textureBuffer,
            offset: 0,
            index: 5
        )
        var color = Color.blue
        encoder.setVertexBytes(
            &color,
            length: MemoryLayout<Color>.stride,
            index: 6
        )
        //
        //            encoder?.setFragmentTexture(shapeTexture, index: 0)
        //            encoder?.setFragmentTexture(granularityTexture, index: 1)
        encoder
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: Buffer.quad.indexCount,
                indexType: .uint16,
                indexBuffer: Buffer.quad.indexBuffer,
                indexBufferOffset: 0,
                instanceCount: points.count
            )
        
        encoder.endEncoding()
    }
}
