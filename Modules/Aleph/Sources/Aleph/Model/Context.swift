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
    
    var compositeTextureId:     TextureID
    
    /// Canvas size
    var canvasSize:             Size
    /// Memory allocator
    let bufferAllocator =       BufferAllocator()
    /// Current working document
    var document:               Document
    /// Passes to be encoded
    var pendingPasses:          [Pass] = []
    /// Passes encoded in a separate command buffer after the display frame
    var deferredPasses:         [Pass] = []
    var liveAnimations:         [Animation] = []
    /// Current brush
    var brush:                  Brush
   
    var strokeContext:          StrokeContext
    var renderContext:          RenderContext
    
    init(clearColor: Color,canvasSize: Size) {
        self.cameraMatrix = .identity
        self.cameraTransform = Transform()
        self.projectionTransform = .identity
        
        self.clearColor = clearColor
        
        canvasGrid = .init(canvasSize: canvasSize, named: "Canvas")
        strokeGrid = .init(canvasSize: canvasSize, named: "Stroke")
        
        compositeTextureId = TextureManager.makeTexture(ofSize: canvasSize)!
        
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
        self.renderContext = . init()
    }
}

class StrokeContext {
    private(set) var shouldClearStrokeGrid:  Bool = false
    private(set) var shouldUpdateLayerGrid:  Bool = false
    var activeStroke:           ActiveStroke?
    private var readySegments:  [StrokeSegment] = []
    
    func setShouldClearStrokeGrid(_ value: Bool) {
        shouldClearStrokeGrid = value
    }
    
    func setShouldUpdateLayerGrid(_ value: Bool) {
        shouldUpdateLayerGrid = value
    }
    
    func addSegments(_ segments: [StrokeSegment]) {
        readySegments.append(contentsOf: segments)
    }
    
    func drainSegments() -> [StrokeSegment] {
        let segments = readySegments
        readySegments = []
        return segments
    }
}

class RenderContext {
    var operationQueue: [RenderSystem.Operation] = []
    
    func enqueue(_ operation: RenderSystem.Operation) {
        operationQueue.append(operation)
    }
}
