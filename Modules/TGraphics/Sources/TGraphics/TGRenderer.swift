import Metal
import simd

class TGRenderer {
    let threadGroupLength = 8
    let pipelineManager: TGPipelinesManager
    
    init(pipelineManager: TGPipelinesManager) {
        self.pipelineManager = pipelineManager
    }
    
    func load() {
        pipelineManager.load()
    }
    
    func fillTexture(
        texture: MTLTexture,
        with color: simd_float4,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard let pipelineState = pipelineManager.computePipeline(ofType: .fill) else {
            return
        }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(
            [color.x, color.y, color.z, color.w],
            length: MemoryLayout<Float>.stride * 4,
            index: 1
        )
        let threadsGroupSize = MTLSize(
            width: (texture.width) / threadGroupLength,
            height: texture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (texture.width) / threadsGroupSize.width,
            height: (texture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
}
