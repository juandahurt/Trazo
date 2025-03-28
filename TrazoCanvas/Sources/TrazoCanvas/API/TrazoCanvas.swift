import UIKit
import TrazoCore
import TrazoEngine

@MainActor
public struct TrazoCanvas {
    /// To hold the controller in memory
    var controller: CanvasController?
    
    public private(set) var canvasView: UIView
    
    public init(descriptor: TrazoCanvasDescriptor) {
        TrazoEngine.load()
        
        let state = CanvasState(
            brushColor: descriptor.brushColor
        )
        let canvasController = CanvasController(state: state)
        let canvasView = CanvasView(fingerGestureDelegate: canvasController)
        canvasView.delegate = canvasController
        canvasController.canvasView = canvasView
        
        controller = canvasController
        
        self.canvasView = canvasView
    }
    
    public func load() {
        controller?.load()
    }
}

public extension TrazoCanvas {
    func setBrushColor(_ color: Vector4) {
        controller?.setBrushColor(color)
    }
}
