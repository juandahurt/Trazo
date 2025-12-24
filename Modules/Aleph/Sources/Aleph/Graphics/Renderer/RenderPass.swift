import MetalKit

protocol RenderPass {
    func encode(
        context: FrameContext,
        resources: RenderResources,
        commandBuffer: MTLCommandBuffer,
        drawable: CAMetalDrawable
    )
    
    func calculateThreads(in texture: MTLTexture) -> (
        groupsPerGrid: MTLSize,
        threadsPerGroup: MTLSize
    )
}

extension RenderPass {
    func calculateThreads(in texture: MTLTexture) -> (
        groupsPerGrid: MTLSize,
        threadsPerGroup: MTLSize
    ) {
        let threadGroupLength = 8
        let threadsGroupsPerGrid = MTLSize(
            width: (texture.width + threadGroupLength - 1) / threadGroupLength,
            height: (texture.height + threadGroupLength - 1) / threadGroupLength,
            depth: 1
        )
        let threadsPerThreadGroup = MTLSize(
            width: threadGroupLength,
            height: threadGroupLength,
            depth: 1
        )
        return (threadsGroupsPerGrid, threadsPerThreadGroup)
    }
}
