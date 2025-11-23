import Metal

extension Renderer {
    func fillTexture(_ texture: MTLTexture, color: Color) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .fill),
            let commandBuffer
        else {
            return
        }
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
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
    }
}
