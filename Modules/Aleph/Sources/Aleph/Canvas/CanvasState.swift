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
    var ctm = matrix_identity_float4x4
    /// Current projection matrix.
    var cpm = matrix_identity_float4x4
    
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
