import MetalKit

//class CommandExcecutor {
//    func excecute(
//        passes: [RenderPass],
//        context: FrameContext,
//        renderResources: RenderResources,
//        drawable: CAMetalDrawable
//    ) {
//        guard let commandBuffer = GPU.commandQueue.makeCommandBuffer() else { return }
//        for pass in passes {
//            pass
//                .encode(
//                    context: context,
//                    resources: renderResources,
//                    commandBuffer: commandBuffer,
//                    drawable: drawable
//                )
//        }
//        commandBuffer.commit()
//    }
//}
