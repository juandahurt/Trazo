import Metal

extension Renderer {
    func colorize(
        texture: Texture,
        withColor color: Color,
        on outputTexture: Texture
    ) {
        commandBuffer?.pushDebugGroup("Colorize Texture \(texture.name)")
        defer { commandBuffer?.popDebugGroup() }
        for index in ctx.dirtyIndices {
            let inputTile = texture.tiles[index]
            let outputTile = outputTexture.tiles[index]
            guard
                let mtlInputTexture = TextureManager.findTexture(id: inputTile.textureId),
                let mtlOutputTexture = TextureManager.findTexture(
                    id: outputTile.textureId
                )
            else {
                return
            }
            colorize(texture: mtlInputTexture, withColor: color, on: mtlOutputTexture)
        }
    }
    
    private func colorize(
        texture: MTLTexture,
        withColor color: Color,
        on outputTexture: MTLTexture
    ) {
        guard
            let commandBuffer,
            let pipelineState = PipelinesManager.computePipeline(for: .colorize)
        else { return }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(texture, index: 0)
        encoder?.setTexture(outputTexture, index: 1)
        var color = color
        encoder?.setBytes(
            &color,
            length: MemoryLayout<Color>.stride,
            index: 0
        )
        var debugColor = Color(.init([0.2, 0.3, 0.1, 0]))
        encoder?.setBytes(
            &debugColor,
            length: MemoryLayout<Color>.stride,
            index: 1
        )
        let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(in: texture)
        encoder?.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        encoder?.endEncoding()
    }
}
