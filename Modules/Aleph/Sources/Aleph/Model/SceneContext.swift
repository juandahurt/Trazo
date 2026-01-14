import Tartarus

struct SceneContext {
    var renderContext: RenderContext
    var layersContext: LayersContext
}

struct LayersContext {
    var layers: [Layer]
    var currentLayerIndex: Int
}

struct RenderContext {
    var transform: Transform = .identity
    var projectionTransform: Transform = .identity
    
    var intermidiateTexture: TextureID
    
    init(
        canvasSize: Size,
        tileSize: Size,
        rows: Int,
        cols: Int
    ) {
        intermidiateTexture = TextureManager.makeTexture(
            ofSize: canvasSize,
            label: "Intermidiate texture"
        )!
    }
}
