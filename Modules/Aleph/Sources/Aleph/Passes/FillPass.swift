import MetalKit

class FillPass: Pass {
    let color: Color
    let tileGrid: TileGrid

    
    init(color: Color, tileGrid: TileGrid) {
        self.color = color
        self.tileGrid = tileGrid
    }
    
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        for tile in tileGrid.flatTiles {
            guard let mtlTexture = TextureManager.findTexture(id: tile.textureId) else { return }
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].clearColor = color.mtlClearColor
            descriptor.colorAttachments[0].loadAction = .clear
            descriptor.colorAttachments[0].texture = mtlTexture
            
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            encoder?.endEncoding()
            
            tile.isDirty = true
        }
    }
}
