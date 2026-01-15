import MetalKit

class FillPass: RenderPass {
    let color: Color
    let textureId: TextureID
    
    init(color: Color, textureId: TextureID) {
        self.color = color
        self.textureId = textureId
    }
    
    func encode(
        context: SceneContext,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        print("encoding fill pass")
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .fill)
        else {
            return
        }
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        guard let texture = TextureManager.findTexture(id: textureId) else { return }
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(
            [color.r, color.g, color.b, color.a],
            length: MemoryLayout<Float>.stride * 4,
            index: 1
        )
        let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(in: texture)
        encoder?.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        encoder?.endEncoding()
        return
        
    }
}
