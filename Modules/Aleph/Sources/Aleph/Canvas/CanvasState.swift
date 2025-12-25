import simd
import Tartarus

struct Layer {
    var name: String
    var isVisible = true
    var texture: TextureID
    
    init(named name: String, texture: TextureID) {
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
            update()
        }
    }
    
    var layers: [Layer] = []
    var currentLayerIndex = 0
    var currentLayer: Layer {
        layers[currentLayerIndex]
    }
    
    var selectedBrush: Brush
    
    init(canvasSize: Size) {
        self.canvasSize = canvasSize
        
        // TODO: move creation to other place
        selectedBrush = .init(
            shapeTextureID: TextureManager.loadTexture(
                fromFile: "default-shape",
                withExtension: "png"
            )!
        )
    }
    
    private mutating func update() {
        tileSize = .init(
            width: canvasSize.width / Float(tilesPerRow),
            height: canvasSize.height / Float(tilesPerColumn)
        )
        layers = [
            .init(
                named: "Background layer",
                texture: TextureManager
                    .makeTiledTexture(
                        named: "Background texture",
                        rows: 8,
                        columns: 8,
                        tileSize: tileSize,
                        canvasSize: canvasSize
                    )
            ),
            .init(
                named: "Layer 1",
                texture: TextureManager
                    .makeTiledTexture(
                        named: "Layer texture 1",
                        rows: 8,
                        columns: 8,
                        tileSize: tileSize,
                        canvasSize: canvasSize
                    )
            )
        ]
        currentLayerIndex = 1
    }
}
