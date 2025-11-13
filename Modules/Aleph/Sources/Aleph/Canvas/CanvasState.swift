import simd
import Tartarus

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
    
    /// Current transform matrix.
    var ctm = Transform.identity
    /// Current projection matrix.
    var cpm = Transform.identity
    
    var renderableTexture: TiledTexture?
    
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
