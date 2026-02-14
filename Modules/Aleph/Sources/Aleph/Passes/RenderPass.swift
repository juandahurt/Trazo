//import MetalKit
//import Tartarus
//
//protocol RenderPass {
//    func encode(
//        context: SceneContext,
//        commandBuffer: MTLCommandBuffer,
//        drawable: CAMetalDrawable
//    )
//    
//    func calculateThreads(in size: Size) -> (
//        groupsPerGrid: MTLSize,
//        threadsPerGroup: MTLSize
//    )
//}
//
//extension RenderPass {
//    func calculateThreads(in size: Size) -> (
//        groupsPerGrid: MTLSize,
//        threadsPerGroup: MTLSize
//    ) {
//        let threadGroupLength = 16
//        let threadsGroupsPerGrid = MTLSize(
//            width: (Int(size.width) + threadGroupLength - 1) / threadGroupLength,
//            height: (Int(size.height) + threadGroupLength - 1) / threadGroupLength,
//            depth: 1
//        )
//        let threadsPerThreadGroup = MTLSize(
//            width: threadGroupLength,
//            height: threadGroupLength,
//            depth: 1
//        )
//        return (threadsGroupsPerGrid, threadsPerThreadGroup)
//    }
//}
