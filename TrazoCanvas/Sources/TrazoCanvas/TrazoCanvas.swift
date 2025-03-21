import UIKit

public struct TrazoCanvas {
    /// To hold the controller in memory
    var controller: CanvasController?
    
    public init() {}
    
    @MainActor
    mutating public func makeCanvas() -> UIView {
        let state = CanvasState()
        let canvasController = CanvasController(state: state)
        let canvasView = CanvasView(fingerGestureDelegate: canvasController)
        canvasController.canvasView = canvasView
        
        controller = canvasController
        
        return canvasView
    }
}
