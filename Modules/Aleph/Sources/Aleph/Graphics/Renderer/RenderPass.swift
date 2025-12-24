import MetalKit

protocol RenderPass {
    func encode(
        context: FrameContext,
        resources: RenderResources,
        commandBuffer: MTLCommandBuffer,
        drawable: CAMetalDrawable
    )
}
