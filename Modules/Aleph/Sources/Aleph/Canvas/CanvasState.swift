import Tartarus

struct CanvasState {
    let tilesPerRow = 8
    let tilesPerColumn = 8
    
    let canvasSize: Size
    let tileSize: Size
    
    var renderableTexture: TiledTexture?
    
    init(canvasSize: Size) {
        self.canvasSize = canvasSize
        
        tileSize = .init(
            width: canvasSize.width / Float(tilesPerRow),
            height: canvasSize.height / Float(tilesPerColumn)
                
        )
    }
}
