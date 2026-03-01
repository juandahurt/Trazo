import Tartarus

struct Layer {
    var name: String
    var tileGrid: TileGrid
    
    init(named name: String, size: Size) {
        self.name = name
        self.tileGrid = TileGrid(canvasSize: size)
    }
}
