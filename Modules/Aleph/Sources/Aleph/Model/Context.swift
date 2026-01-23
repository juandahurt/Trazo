import Tartarus

class Context {
    /// Canvas camera transform
    var cameraTransform:        Transform
    /// projection transform
    var projectionTransform:    Float4x4
    /// Clear color
    var clearColor:             Color
    /// Main texture
    var canvasTexture:          TextureID
    /// Canvas size
    var canvasSize:             Size
    
    init(
        cameraTransform: Transform = .init(),
        projectionTransform: Float4x4 = .identity,
        clearColor: Color,
        canvasTexture: TextureID,
        canvasSize: Size
    ) {
        self.cameraTransform = cameraTransform
        self.projectionTransform = projectionTransform
        self.clearColor = clearColor
        self.canvasTexture = canvasTexture
        self.canvasSize = canvasSize
    }
}
