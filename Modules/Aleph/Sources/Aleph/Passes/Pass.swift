import MetalKit

protocol Pass {
    /// <#Description#>
    /// - Parameters:
    ///   - commandBuffer: <#commandBuffer description#>
    ///   - drawable: <#drawable description#>
    func encode(commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable, ctx: Context)
}
