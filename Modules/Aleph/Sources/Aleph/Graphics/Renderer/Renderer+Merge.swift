import Metal

extension Renderer {
    func merge(
        _ sourceTexture: Texture,
        with secondTexture: Texture,
        on destinationTexture: Texture
    ) {
        guard
            let commandBuffer,
            let pipelineState = PipelinesManager.computePipeline(for: .merge)
        else {
            return
        }
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        for index in ctx.dirtyIndices {
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
    }
}
