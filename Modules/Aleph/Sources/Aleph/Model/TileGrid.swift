import Metal
import Tartarus

class TileGrid {
    static let tileSize = 64
    
    let cols: Int
    let rows: Int
    
    private(set) var tiles: [[Tile]] = []
    
    var flatTiles: [Tile] {
        tiles.flatMap { $0 }
    }
    
    var dirtyTiles: [Tile] {
        flatTiles.filter { $0.isDirty }
    }
    
    init(canvasSize: Size) {
        let tileSize = Self.tileSize
        
        let canvasWidth = Int(canvasSize.width)
        let canvasHeight = Int(canvasSize.height)
        
        cols = (canvasWidth + tileSize - 1) / tileSize
        rows = (canvasHeight + tileSize - 1) / tileSize
        tiles = buildGrid()
    }
   
    func tiles(intersecting rect: Rect) -> [Tile] {
        let tileSize = Float(Self.tileSize)
        
        let minCol = max(0, Int(floor(rect.x / tileSize)))
        let minRow = max(0, Int(floor(rect.y / tileSize)))
        let maxCol = min(cols - 1, Int(floor((rect.x + rect.width  - 1) / tileSize)))
        let maxRow = min(rows - 1, Int(floor((rect.y + rect.height - 1) / tileSize)))
        
        guard minCol <= maxCol, minRow <= maxRow else { return [] }
        
        var result: [Tile] = []
        
        for row in minRow...maxRow {
            for col in minCol...maxCol {
                result.append(tiles[row][col])
            }
        }
        
        return result
    }
    
    func clear(using commandBuffer: MTLCommandBuffer) {
        for tile in flatTiles {
            guard let texture = TextureManager.findTexture(id: tile.textureId)
            else { return }
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].clearColor = Color.clear.mtlClearColor
            descriptor.colorAttachments[0].texture = texture
            descriptor.colorAttachments[0].loadAction = .clear
            descriptor.colorAttachments[0].storeAction = .store
            
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            encoder?.endEncoding()
            
            tile.isDirty = true
        }
    }
    
    private func buildGrid() -> [[Tile]] {
        let size = Size(
            width: Float(Self.tileSize),
            height: Float(Self.tileSize)
        )
        return (0..<rows).map { row in
            (0..<cols).map { col in
                let texture = TextureManager.makeTexture(ofSize: size)
                return Tile(col: col, row: row, textureId: texture!)
            }
        }
    }
}
