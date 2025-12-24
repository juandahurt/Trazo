import Tartarus

class RenderResources {
    let intermidiateTexture: TextureID
    
    init(canvasSize: Size) {
        intermidiateTexture = TextureManager.makeTexture(ofSize: canvasSize)!
    }
}
