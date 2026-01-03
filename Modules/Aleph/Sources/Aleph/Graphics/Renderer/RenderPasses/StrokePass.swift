import MetalKit
import Tartarus

class StrokePass: RenderPass {
    let shapeTextureId: TextureID
    
    init(shapeTextureId: TextureID) {
        self.shapeTextureId = shapeTextureId
    }
    
    func encode(
        context: FrameContext,
        resources: RenderResources,
        commandBuffer: any MTLCommandBuffer,
        drawable: CAMetalDrawable
    ) {
        commandBuffer.pushDebugGroup("Draw grayscale points")
        defer { commandBuffer.popDebugGroup() }
        guard
            let pipelineState = PipelinesManager.renderPipeline(
                for: .drawGrayscalePoints
            ),
            let grayscaleTexture = TextureManager.findTiledTexture(
                id: resources.grayscaleTexture
            ),
            let shapeTexture = TextureManager.findTexture(id: shapeTextureId)
        else {
            return
        }
        // TODO: use only one buffer
        let nonEmptySegments = context.segments.filter { !$0.points.isEmpty }
        let points: [DrawablePoint] = nonEmptySegments
            .reduce([], { $0 + $1.points })
        guard !points.isEmpty else { return }
        for index in context.dirtyTiles {
            let tile = grayscaleTexture.tiles[index]
            guard let outputTexture = TextureManager.findTexture(id: tile.textureId) else {
                return
            }
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = outputTexture
            passDescriptor.colorAttachments[0].loadAction = .load
            passDescriptor.colorAttachments[0].storeAction = .store
            
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
            encoder?.setRenderPipelineState(pipelineState)
            encoder?.setVertexBuffer(Buffer.quad.vertexBuffer, offset: 0, index: 0)
            
            let tranforms: [Transform] = points.map {
                .init(
                    translateByX: $0.position.x - tile.bounds.x,
                    y: $0.position.y - tile.bounds.y
                )
                .concatenating(.init(rotatedBy: $0.angle))
                .concatenating(.init(scaledBy: $0.size * context.ctm.scale))
            }
            let transformsBuffer = GPU.device
                .makeBuffer(
                    bytes: tranforms,
                    length: MemoryLayout<Transform>.stride * tranforms.count
                )
            
            var opacity: Float = context.opacity
            var view = Transform.identity
                .concatenating(
                    .init(
                        translateByX: 0,
                        y: resources.tileSize.height
                    )
                )
                .concatenating(
                    .init(
                        scaledByX: 1,
                        y: -1
                    )
                )
                .concatenating(context.ctm.inverse)
            encoder?.setVertexBytes(
                &view,
                length: MemoryLayout<Transform.Matrix>.stride,
                index: 1
            )
            let viewSize = Float(outputTexture.height)
            let aspect = Float(outputTexture.width) / Float(outputTexture.height)
            let halfW = resources.tileSize.width / 2
            let halfH = resources.tileSize.height / 2
            let rect = Rect(
                x: 0,
                y: resources.tileSize.height,
                width: resources.tileSize.width,
                height: resources.tileSize.height
            )
            var pm = Transform(
                ortho: rect,
                near: 0,
                far: 1
            )
            encoder?.setVertexBytes(
                &pm,
                length: MemoryLayout<Transform.Matrix>.stride,
                index: 2
            )
            encoder?.setVertexBytes(
                &opacity,
                length: MemoryLayout<Float>.stride,
                index: 3
            )
            encoder?.setVertexBuffer(
                transformsBuffer,
                offset: 0,
                index: 4
            )
            encoder?.setVertexBuffer(
                Buffer.quad.textureBuffer,
                offset: 0,
                index: 5
            )
            
            encoder?.setFragmentTexture(shapeTexture, index: 0)
            //        encoder?.setFragmentTexture(granularityTexture, index: 1)
            encoder?
                .drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: Buffer.quad.indexCount,
                    indexType: .uint16,
                    indexBuffer: Buffer.quad.indexBuffer,
                    indexBufferOffset: 0,
                    instanceCount: points.count
                )
            
            encoder?.endEncoding()
        }
    }
}
