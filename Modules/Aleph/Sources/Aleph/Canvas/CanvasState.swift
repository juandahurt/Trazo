import simd
import Tartarus

struct Layer {
    var name: String
    var texture: Texture
    
    init(named name: String, texture: Texture) {
        self.name = name
        self.texture = texture
    }
}

struct CanvasState {
    let tilesPerRow = 8
    let tilesPerColumn = 8
    
    var canvasSize: Size
    var tileSize: Size = .zero
    var contentScaleFactor: Float = 1 {
        didSet {
            canvasSize.width *= contentScaleFactor
            canvasSize.height *= contentScaleFactor
            updateTileSize()
        }
    }
    
    var renderableTexture: Texture?
    var grayscaleTexture: Texture?
    var strokeTexture: Texture?
    
    var layers: [Layer] = []
    var currentLayerIndex = -1
    
    init(canvasSize: Size) {
        self.canvasSize = canvasSize
    }
    
    private mutating func updateTileSize() {
        tileSize = .init(
            width: canvasSize.width / Float(tilesPerRow),
            height: canvasSize.height / Float(tilesPerColumn)
        )
    }
}
