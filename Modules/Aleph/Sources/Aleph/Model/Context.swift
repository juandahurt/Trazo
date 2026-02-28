import Foundation
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
    /// Stroke texture
    var strokeTexture:          TextureID
    /// Canvas size
    var canvasSize:             Size
    /// Memory allocator
    let bufferAllocator =       BufferAllocator()
    /// Current working document
    var document:               Document
    /// Passes to be encoded
    var pendingPasses:          [Pass] = []
    /// Current brush
    var brush:                  Brush
   
    var strokeContext:          StrokeContext
    
    init(
        clearColor: Color,
        canvasTexture: TextureID,
        strokeTexture: TextureID,
        canvasSize: Size
    ) {
        self.cameraMatrix = .identity
        self.cameraTransform = Transform()
        self.projectionTransform = .identity
        self.clearColor = clearColor
        self.canvasTexture = canvasTexture
        self.strokeTexture = strokeTexture
        self.canvasSize = canvasSize
        self.document = .init(
            layers: [
                .init(named: "Background", size: canvasSize),
                .init(named: "Layer 1", size: canvasSize)
            ],
            currentLayerIndex: 1
        )
        self.brush = .init(
            shapeTextureID: 0,
            granularityTextureID: 0,
            spacing: 2,
            pointSize: 5,
            opacity: 1,
            blendMode: .normal
        )
        self.strokeContext = .init()
    }
}

class StrokeContext {
    /// Current stroke
    var activeStroke:           ActiveStroke?
    private var readySegments:  [StrokeSegment] = []
    private let lock =          NSLock()
    
    func addSegments(_ segments: [StrokeSegment]) {
        lock.lock()
        readySegments.append(contentsOf: segments)
        lock.unlock()
    }
    
    func drainSegments() -> [StrokeSegment] {
        lock.lock()
        let segments = readySegments
        readySegments = []
        lock.unlock()
        return segments
    }
}
