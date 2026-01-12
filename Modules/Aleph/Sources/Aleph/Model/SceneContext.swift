import Tartarus

struct SceneContext {
    var renderContext: RenderContext
}

struct RenderContext {
    var baseTransform = Transform.identity
    var currentTransform = Transform.identity
    var transform: Transform { currentTransform.concatenating(baseTransform) }
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
