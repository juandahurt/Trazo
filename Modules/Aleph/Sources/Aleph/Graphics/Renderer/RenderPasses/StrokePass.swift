import MetalKit

class StrokePass: RenderPass {
    func encode(
        context: FrameContext,
        resources: RenderResources,
        commandBuffer: any MTLCommandBuffer,
        drawable: CAMetalDrawable
    ) {
        print("encoding stroke pass")
    }
}
