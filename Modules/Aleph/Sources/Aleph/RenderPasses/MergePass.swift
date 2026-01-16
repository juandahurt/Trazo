import MetalKit

class MergePass: RenderPass {
    func encode(
        context: SceneContext,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        for index in stride(
            from: context.layersContext.layers.count - 1,
            to: -1,
            by: -1
        ) {
            let layerTextureId = context.layersContext.layers[index].texture
            guard
                let layerTexture = TextureManager.findTexture(id: layerTextureId),
                let outputTexture = TextureManager.findTexture(id: context.renderContext.renderableTexture)
            else {
                return
            }
            merge(
                outputTexture,
                with: layerTexture,
                on: outputTexture,
                using: commandBuffer,
                context: context
            )
        }
    }
    
    func merge(
        _ sourceTexture: MTLTexture,
        with secondTexture: MTLTexture,
        on destinationTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        context: SceneContext
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .merge)
        else {
            return
        }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(sourceTexture, index: 0)
        encoder?.setTexture(secondTexture, index: 1)
        encoder?.setTexture(destinationTexture, index: 2)

        let tiles: [TileRect] = context.dirtyContext.dirtyIndices.map {
            let row = $0 / context.renderContext.cols
            let col = $0 % context.renderContext.cols
            let minX: UInt32 = UInt32(Float(col) * context.renderContext.tileSize.width)
            let minY: UInt32 = UInt32(Float(row) * context.renderContext.tileSize.height)
            return .init(
                origin: [minX, minY],
                size: [
                    UInt32(context.renderContext.tileSize.width),
                    UInt32(context.renderContext.tileSize.height)
                ]
            )
        }
        let tileBuffer = GPU.device.makeBuffer(
            bytes: tiles,
            length: MemoryLayout<TileRect>.stride * tiles.count,
            options: []
        )

        encoder?.setBuffer(tileBuffer, offset: 0, index: 0)
        
        let tgPerTile = 4
        let threadsPerTG = 16
        let threadgroups = MTLSize(
            width: tiles.count * tgPerTile,
            height: tgPerTile,
            depth: 1
        )

        let threadsPerThreadgroup = MTLSize(
            width: threadsPerTG,
            height: threadsPerTG,
            depth: 1
        )

        encoder?.dispatchThreadgroups(
            threadgroups,
            threadsPerThreadgroup: threadsPerThreadgroup
        )

        encoder?.endEncoding()
    }
}

fileprivate struct TileRect {
    var origin: SIMD2<UInt32>
    var size: SIMD2<UInt32>
}
