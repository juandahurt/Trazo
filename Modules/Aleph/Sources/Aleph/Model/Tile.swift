import Tartarus

class Tile {
    let col: Int
    let row: Int
    
    let textureId: TextureID
    
    var isDirty: Bool = false
    
    var origin: Point {
        .init(
            x: Float(col * TileGrid.tileSize),
            y: Float(row * TileGrid.tileSize)
        )
    }
    
    var rect: Rect {
        .init(
            x: origin.x,
            y: origin.y,
            width: Float(TileGrid.tileSize),
            height: Float(TileGrid.tileSize)
        )
    }
    
    init(col: Int, row: Int, textureId: TextureID) {
        self.col = col
        self.row = row
        self.textureId = textureId
    }
}
