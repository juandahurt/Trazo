import UIKit
import TrazoCore
import TrazoEngine

@MainActor
public class TrazoCanvas {
    /// To hold the controller in memory
    var controller: CanvasController?
    
    public private(set) var canvasView: UIView
    public weak var delegate: TrazoCanvasDelegate?
    
    public init(descriptor: TrazoCanvasDescriptor) {
        TrazoEngine.load()
        
        let state = CanvasState(
            brushColor: descriptor.brushColor,
            brushSize: descriptor.brushSize
        )
        let canvasController = CanvasController(state: state)
        let canvasView = CanvasView(fingerGestureDelegate: canvasController)
        canvasView.delegate = canvasController
        canvasController.canvasView = canvasView
        
        controller = canvasController
        
        self.canvasView = canvasView
        
        canvasController.delegate = self
    }
    
    public func load() {
        controller?.load()
    }
}

public extension TrazoCanvas {
    func setBrushColor(_ color: Vector4) {
        controller?.setBrushColor(color)
    }
    
    func setBrushSize(_ size: Float) {
        controller?.setBrushSize(size)
    }
    
    func setIsVisible(_ isVisible: Bool, toLayerAtIndex index: Int) {
        controller?.setIsVisible(isVisible, toLayerAtIndex: index)
    }
}
