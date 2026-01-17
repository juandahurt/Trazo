import Tartarus

struct SceneContext {
    var renderContext:  RenderContext
    var layersContext:  LayersContext
    var dirtyContext:   DirtContext
    var strokeContext:  StrokeContext
}

struct StrokeContext {
    var touches: [Touch] = []
    var offset: Float = 0
    var brush = Brush(
        shapeTextureID: 0, // TODO: pass correct values
        granularityTextureID: 0,
        spacing: 8,
        pointSize: 20,
        opacity: 1
    )
    var segments: [StrokeSegment] = []
}

struct DirtContext {
    var dirtyIndices: Set<Int>
}

struct LayersContext {
    var layers: [Layer]
    var currentLayerIndex: Int
}

struct RenderContext {
    enum RenderOperation {
        case fill(color: Color, texture: TextureID)
        case merge(isDrawing: Bool)
        case draw(StrokeSegment)
    }
    
    // MARK: Operations
    var operations:             [RenderOperation] = []
    
    // MARK: Transforms
    var transform:              Transform = .identity
    var projectionTransform:    Transform = .identity
    
    // MARK: Textures
    var renderableTexture:      TextureID
    var strokeTexture:          TextureID
    
    // MARK: Canvas
    let canvasSize:             Size
    let tileSize:               Size
    let rows:                   Int
    let cols:                   Int
    
    init(
        canvasSize: Size,
        tileSize: Size,
        rows: Int,
        cols: Int
    ) {
        renderableTexture = TextureManager.makeTexture(
            ofSize: canvasSize,
            label: "Renderable texture"
        )!
        strokeTexture = TextureManager.makeTexture(
            ofSize: canvasSize,
            label: "Stroke texture"
        )!
        self.canvasSize = canvasSize
        self.tileSize = tileSize
        self.rows = rows
        self.cols = cols
    }
}
