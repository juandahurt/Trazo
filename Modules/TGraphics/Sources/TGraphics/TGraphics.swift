import simd

public struct TGraphics {
    let textureManager = TGTextureManager()
    
    public func makeTexture(ofSize size: simd_long2, label: String? = nil) -> Int? {
        textureManager.makeTexture(ofSize: size, label: label)
    }
}
