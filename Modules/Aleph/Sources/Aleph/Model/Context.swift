import Tartarus

class Context {
    /// Canvas camera transform
    var cameraMatrix:           Float4x4
    var cameraTransform:        Transform
    /// projection transform
    var projectionTransform:    Float4x4
    /// Clear color
    var clearColor:             Color
    /// Main texture
    var canvasTexture:          TextureID
    /// Canvas size
    var canvasSize:             Size
    /// Memory allocator
    let bufferAllocator =       BufferAllocator()
    /// Current stroke
    var activeStroke:           ActiveStroke?
    /// Current working document
    var document:               Document
    /// Passes to be encoded
    var pendingPasses:  [Pass] = []
    
    init(
        clearColor: Color,
        canvasTexture: TextureID,
        canvasSize: Size
    ) {
        self.cameraMatrix = .identity
        self.cameraTransform = Transform()
        self.projectionTransform = .identity
        self.clearColor = clearColor
        self.canvasTexture = canvasTexture
        self.canvasSize = canvasSize
        self.document = .init(
            layers: [
                .init(named: "Background", size: canvasSize),
                .init(named: "Layer 1", size: canvasSize)
            ],
            currentLayerIndex: 1
        )
    }
}
