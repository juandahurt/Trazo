import UIKit
import TrazoEngine

@MainActor
public struct TrazoCanvas {
    /// To hold the controller in memory
    var controller: CanvasController?
    
    public private(set) var canvasView: UIView
    
    public init() {
        TrazoEngine.load()
        
        let state = CanvasState()
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
