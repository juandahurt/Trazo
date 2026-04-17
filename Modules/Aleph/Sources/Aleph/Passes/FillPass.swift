import Tartarus
import MetalKit

class FillPass: Pass {
    let color: Color
    let tileGrid: TileGrid
    let dirtyArea: Rect?

    init(color: Color, tileGrid: TileGrid, dirtyArea: Rect? = nil) {
        self.color = color
        self.tileGrid = tileGrid
        self.dirtyArea = dirtyArea
    }

    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        let tiles = dirtyArea.map { tileGrid.tiles(intersecting: $0) } ?? tileGrid.flatTiles
        for tile in tiles {
            guard let mtlTexture = TextureManager.findTexture(id: tile.textureId) else { continue }
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
