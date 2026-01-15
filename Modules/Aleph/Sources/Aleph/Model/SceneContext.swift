import Tartarus

struct SceneContext {
    var renderContext: RenderContext
    var layersContext: LayersContext
    var dirtyContext: DirtContext
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
    }
    
    // MARK: Operations
    var operations: [RenderOperation] = []
    
    // MARK: Transforms
    var transform: Transform = .identity
    var projectionTransform: Transform = .identity
    
    // MARK: Textures
    var renderableTexture: TextureID
    
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
    }
}
