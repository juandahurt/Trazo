import MetalKit

class ColorizePass: RenderPass {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    func encode(
        context: FrameContext,
        resources: RenderResources,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        commandBuffer.pushDebugGroup("Colorization")
        defer { commandBuffer.popDebugGroup() }
        guard
            let encoder = commandBuffer.makeComputeCommandEncoder(),
            let grayscaleTexture = TextureManager.findTiledTexture(
                id: resources.grayscaleTexture
            ),
            let strokeTexture = TextureManager.findTiledTexture(
                id: resources.strokeTexture
            )
        else { return }
        for index in context.dirtyTiles {
            let inputTile = grayscaleTexture.tiles[index]
            let outputTile = strokeTexture.tiles[index]
            guard
                let mtlInputTexture = TextureManager.findTexture(id: inputTile.textureId),
                let mtlOutputTexture = TextureManager.findTexture(
                    id: outputTile.textureId
                )
            else {
                return
            }
            colorize(
                texture: mtlInputTexture,
                withColor: color,
                on: mtlOutputTexture,
                using: commandBuffer,
                encoder: encoder
            )
        }
        encoder.endEncoding()
    }
    
    private func colorize(
        texture: MTLTexture,
        withColor color: Color,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        encoder: MTLComputeCommandEncoder
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .colorize)
        else { return }
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(texture, index: 0)
        encoder.setTexture(outputTexture, index: 1)
        var color = color
        encoder.setBytes(
            &color,
            length: MemoryLayout<Color>.stride,
            index: 0
        )
        var debugColor = Color(.init([0, 0, 0, 0]))
        encoder.setBytes(
            &debugColor,
            length: MemoryLayout<Color>.stride,
            index: 1
        )
        let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(in: texture)
        encoder.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
    }
}
