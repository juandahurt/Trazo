import Metal

extension Renderer {
    func merge(
        layers: [Layer],
        currentLayerIndex: Int,
        renderableTexture: Texture,
        strokeTexture: Texture,
        usingStrokeTexture: Bool = true
    ) {
        guard let commandBuffer = GPU.commandQueue.makeCommandBuffer() else { return }
        fillTexture(
            renderableTexture,
            color: .clear,
            onlyDirtTiles: true,
            using: commandBuffer
        )
        for index in stride(from: layers.count - 1, to: -1, by: -1) {
            //            if !state.layers[index].isVisible { continue }
            if index == currentLayerIndex && usingStrokeTexture {
                merge(
                    renderableTexture,
                    with: strokeTexture,
                    on: renderableTexture,
                    using: commandBuffer
                )
            } else {
                merge(
                    renderableTexture,
                    with: layers[index].texture,
                    on: renderableTexture,
                    using: commandBuffer
                )
            }
        }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func merge(
        _ sourceTexture: Texture,
        with secondTexture: Texture,
        on destinationTexture: Texture,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .merge)
        else {
            return
        }
       
        commandBuffer
            .pushDebugGroup("Merging \(sourceTexture.name) with \(secondTexture.name)")
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        for index in ctx.getDirtyIndices() {
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
