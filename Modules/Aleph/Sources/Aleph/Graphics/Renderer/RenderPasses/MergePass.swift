import MetalKit

class MergePass: RenderPass {
    let layersTexturesIds: [TextureID]
    let onlyDirtyIndices: Bool
    
    init(
        layersTexturesIds: [TextureID],
        onlyDirtyIndices: Bool
    ) {
        self.layersTexturesIds = layersTexturesIds
        self.onlyDirtyIndices = onlyDirtyIndices
    }
    
    func encode(
        context: FrameContext,
        resources: RenderResources,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        print("encoding merge", context.dirtyTiles)
        // TODO: clear ouput texture
        for index in stride(from: layersTexturesIds.count - 1, to: -1, by: -1) {
            let layerTextureId = layersTexturesIds[index]
            guard
                let layerTexture = TextureManager.findTiledTexture(id: layerTextureId),
                let outputTexture = TextureManager.findTiledTexture(
                    id: resources.renderableTexture
                )
            else {
                return
            }
            merge(
                outputTexture,
                with: layerTexture,
                on: outputTexture,
                using: commandBuffer,
                context: context,
                resources: resources
            )
        }
    }
    
    func merge(
        _ sourceTexture: Texture,
        with secondTexture: Texture,
        on destinationTexture: Texture,
        using commandBuffer: MTLCommandBuffer,
        context: FrameContext,
        resources: RenderResources
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .merge)
        else {
            return
        }
        print("will merge", context.dirtyTiles)
        commandBuffer
            .pushDebugGroup("Merging \(sourceTexture.name) with \(secondTexture.name)")
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        let indices = onlyDirtyIndices ? context.dirtyTiles : Set(0..<(resources.rows * resources.cols))
        for index in indices {
            let sourceTile = sourceTexture.tiles[index]
            let secondTile = secondTexture.tiles[index]
            let destTile = destinationTexture.tiles[index]
            
            guard
                let mtlSourceTexture = TextureManager.findTexture(id: sourceTile.textureId),
                let mtlSecondTexture = TextureManager.findTexture(id: secondTile.textureId),
                let mtlDestTexture = TextureManager.findTexture(id: destTile.textureId)
            else { return }
            
            encoder?.setTexture(mtlSourceTexture, index: 0)
            encoder?.setTexture(mtlSecondTexture, index: 1)
            encoder?.setTexture(mtlDestTexture, index: 2)
            let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(
                in: mtlDestTexture
            )
            encoder?.dispatchThreadgroups(
                threadgroupsPerGrid,
                threadsPerThreadgroup: threadsPerThreadgroup
            )
        }
        encoder?.endEncoding()
        commandBuffer.popDebugGroup()
    }
}
