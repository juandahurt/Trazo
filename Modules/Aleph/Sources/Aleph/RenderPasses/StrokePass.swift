//import MetalKit
//import Tartarus
//
//class StrokePass: RenderPass {
//    let shapeTextureId: TextureID
//    let granularityTextureId: TextureID
//    let color: Color
//    
//    init(shapeTextureId: TextureID, granularityTextureId: TextureID, color: Color) {
//        self.shapeTextureId = shapeTextureId
//        self.granularityTextureId = granularityTextureId
//        self.color = color
//    }
//    
//    func encode(
//        context: FrameContext,
//        resources: RenderResources,
//        commandBuffer: any MTLCommandBuffer,
//        drawable: CAMetalDrawable
//    ) {
//        commandBuffer.pushDebugGroup("Draw grayscale points")
//        defer { commandBuffer.popDebugGroup() }
//        guard
//            let pipelineState = PipelinesManager.renderPipeline(
//                for: .drawGrayscalePoints
//            ),
//            let grayscaleTexture = TextureManager.findTiledTexture(
//                id: resources.strokeTexture
//            ),
//            let shapeTexture = TextureManager.findTexture(id: shapeTextureId),
//            let granularityTexture = TextureManager.findTexture(id: granularityTextureId)
//        else {
//            return
//        }
//        // TODO: use only one buffer
//        let nonEmptySegments = context.segments.filter { !$0.points.isEmpty }
//        let points: [DrawablePoint] = nonEmptySegments
//            .reduce([], { $0 + $1.points })
//        guard !points.isEmpty else { return }
//        for index in context.dirtyTiles {
//            let tile = grayscaleTexture.tiles[index]
//            guard let outputTexture = TextureManager.findTexture(id: tile.textureId) else {
//                return
//            }
//            let passDescriptor = MTLRenderPassDescriptor()
//            passDescriptor.colorAttachments[0].texture = outputTexture
//            passDescriptor.colorAttachments[0].loadAction = .load
//            passDescriptor.colorAttachments[0].storeAction = .store
//            
//            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
//            encoder?.setRenderPipelineState(pipelineState)
//            encoder?.setVertexBuffer(Buffer.quad.vertexBuffer, offset: 0, index: 0)
//           
//            let tranforms: [Transform] = points.map {
//                Transform.identity
//                    .concatenating(.init(rotatedBy: $0.angle))
//                    .concatenating(.init(scaledBy: $0.size * context.ctm.scale))
//                    .concatenating(.init(translateByX: $0.position.x,y: $0.position.y))
//            }
//            let transformsBuffer = GPU.device
//                .makeBuffer(
//                    bytes: tranforms,
//                    length: MemoryLayout<Transform>.stride * tranforms.count
//                )
//            
//            var opacity: Float = context.opacity
//            var view = Transform.identity
//                .concatenating(context.ctm.inverse)
//                .concatenating(.init(translateByX: -tile.bounds.x, y: -tile.bounds.y))
//                .concatenating(
//                    .init(
//                        scaledByX: 1,
//                        y: -1
//                    )
//                )
//                .concatenating(
//                    .init(
//                        translateByX: 0,
//                        y: resources.tileSize.height
//                    )
//                )
//            encoder?.setVertexBytes(
//                &view,
//                length: MemoryLayout<Transform.Matrix>.stride,
//                index: 1
//            )
//            let viewSize = Float(outputTexture.height)
//            let rect = Rect(
//                x: 0,
//                y: 0,
//                width: resources.tileSize.width,
//                height: resources.tileSize.height
//            )
//            var pm = Transform(
//                ortho: rect,
//                near: 0,
//                far: 1
//            )
//            encoder?.setVertexBytes(
//                &pm,
//                length: MemoryLayout<Transform.Matrix>.stride,
//                index: 2
//            )
//            encoder?.setVertexBytes(
//                &opacity,
//                length: MemoryLayout<Float>.stride,
//                index: 3
//            )
//            encoder?.setVertexBuffer(
//                transformsBuffer,
//                offset: 0,
//                index: 4
//            )
//            encoder?.setVertexBuffer(
//                Buffer.quad.textureBuffer,
//                offset: 0,
//                index: 5
//            )
//            var color = color
//            encoder?.setVertexBytes(
//                &color,
//                length: MemoryLayout<Color>.stride,
//                index: 6
//            )
//            
//            encoder?.setFragmentTexture(shapeTexture, index: 0)
//            encoder?.setFragmentTexture(granularityTexture, index: 1)
//            encoder?
//                .drawIndexedPrimitives(
//                    type: .triangle,
//                    indexCount: Buffer.quad.indexCount,
//                    indexType: .uint16,
//                    indexBuffer: Buffer.quad.indexBuffer,
//                    indexBufferOffset: 0,
//                    instanceCount: points.count
//                )
//            
//            encoder?.endEncoding()
//        }
//    }
//}
