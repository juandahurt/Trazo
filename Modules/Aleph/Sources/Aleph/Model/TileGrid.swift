import Tartarus

class TileGrid {
    static let tileSize = 64
    
    let cols: Int
    let rows: Int
    
    private(set) var tiles: [[Tile]] = []
    
    init(canvasSize: Size) {
        let tileSize = Self.tileSize
        
        let canvasWidth = Int(canvasSize.width)
        let canvasHeight = Int(canvasSize.height)
        
        cols = (canvasWidth + tileSize - 1) / tileSize
        rows = (canvasHeight + tileSize - 1) / tileSize
        tiles = buildGrid()
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
