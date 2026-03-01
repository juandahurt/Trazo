import Foundation
import Tartarus

class Context {
    // MARK: - Transforms
    var cameraMatrix:           Float4x4
    var cameraTransform:        Transform
    var projectionTransform:    Float4x4
    
    /// Clear color
    var clearColor:             Color
    
    // MARK: - Tile grids
    /// Main texture
    var canvasGrid:             TileGrid
    /// Stroke texture
    var strokeGrid:             TileGrid
    
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
    
    init(clearColor: Color,canvasSize: Size) {
        self.cameraMatrix = .identity
        self.cameraTransform = Transform()
        self.projectionTransform = .identity
        self.clearColor = clearColor
        canvasGrid = .init(canvasSize: canvasSize)
        strokeGrid = .init(canvasSize: canvasSize)
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
    private(set) var shouldClearStrokeGrid:  Bool = false
    var activeStroke:           ActiveStroke?
    private var readySegments:  [StrokeSegment] = []
    private let lock =          NSLock()
    
    func setShouldClearStrokeGrid(_ value: Bool) {
        shouldClearStrokeGrid = value
    }
    
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
