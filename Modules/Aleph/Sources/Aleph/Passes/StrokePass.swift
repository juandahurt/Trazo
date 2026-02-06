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
        commandBuffer.pushDebugGroup("Stroke")
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
            &ctx.projectionTransform,
            length: MemoryLayout<Float4x4>.stride,
            index: 1
        )
        
        var opacity: Float = ctx.brush.opacity
        encoder.setVertexBytes(
            &opacity,
            length: MemoryLayout<Float>.stride,
            index: 2
        )
        
        let points = segments.reduce([], { $0 + $1.points })
        let transforms = points.map {
            Float4x4(scaledBy: $0.size)
                .concatenating(.init(rotatedBy: $0.angle))
                .concatenating(Float4x4(translateByX: $0.position.x, y: $0.position.y))
        }
        let (transformsBuffer, transformsOffset) = ctx.bufferAllocator.alloc(transforms)
        encoder.setVertexBuffer(transformsBuffer, offset: transformsOffset, index: 3)

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
            index: 4
        )
        
        var color = Color([0.19, 0.211, 0.219, 1])
        encoder.setVertexBytes(&color, length: MemoryLayout<Color>.size, index: 5)
       
        // MARK: Index buffer
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        let (indexBuffer, indexBufferOffset) = ctx.bufferAllocator.alloc(indices)
   
        guard let shapeTexture = TextureManager.findTexture(id: ctx.brush.shapeTextureID)
        else { return }
        encoder.setFragmentTexture(shapeTexture, index: 0)
        
        guard let granuralityTexture = TextureManager.findTexture(
            id: ctx.brush.granularityTextureID
        ) else { return }
        encoder.setFragmentTexture(granuralityTexture, index: 1)
        
        let union = segments.boundsUnion()
        let dirtyArea = union.clip(
            .init(
                x: 0,
                y: 0,
                width: ctx.canvasSize.width,
                height: ctx.canvasSize.height
            )
        )
        encoder.setScissorRect(
            .init(
                x: Int(dirtyArea.x),
                y: Int(dirtyArea.y),
                width: Int(dirtyArea.width),
                height: Int(dirtyArea.height)
            )
        )
        
//        if #available(iOS 13.0, *) {
//            let rect = dirtyArea
//            let shape = CAShapeLayer()
//            shape.path = .init(
//                rect: .init(
//                    x: CGFloat(
//                        rect.x / 2
//                    ),
//                    y: CGFloat(rect.y / 2),
//                    width: CGFloat(rect.width),
//                    height: CGFloat(rect.height)
//                ),
//                transform: nil
//            )
//            shape.fillColor = UIColor.blue.cgColor.copy(alpha: 0.1)
//            drawable.layer.addSublayer(shape)
//        } else {
//            // Fallback on earlier versions
//        }
        
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
        commandBuffer.popDebugGroup()
    }
}


extension Collection where Element == StrokeSegment {
    func boundsUnion() -> Rect {
        guard let first else { return .zero }
        
        var firstRect = first.bounds
        
        return reduce(firstRect, { $0.union($1.bounds) })
    }
}
