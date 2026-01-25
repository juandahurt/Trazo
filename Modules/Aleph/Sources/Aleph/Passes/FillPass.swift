import MetalKit

class FillPass: Pass {
    let color: Color
    let texture: TextureID

    
    init(color: Color, texture: TextureID) {
        self.color = color
        self.texture = texture
    }
    
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        guard let mtlTexture = TextureManager.findTexture(id: texture) else { return }
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = .init(
            red: color.r,
            green: color.g,
            blue: color.b,
            alpha: color.a
        )
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].texture = mtlTexture
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        encoder?.endEncoding()
    }
}
