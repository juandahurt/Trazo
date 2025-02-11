//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import UIKit

struct DrawableTouch {
    var positionInTextCoord: CGPoint
    var phase: UITouch.Phase
}

class ViewModel {
    private var _canvasState: CanvasState!
    private var _drawingWorkflow = DrawingWorkflow()
    private let _setupWorkflow = SetupCanvasWorkflow()
   
    func scaleUpdated(newValue scale: CGFloat) {
        // TODO: fix issue where canvas keeps drawing the last point
        // TODO: update scale
        // TODO: redraw canvas clearing the background
    }
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        _canvasState.inputTouch = touch
        
        _drawingWorkflow.run(withState: &_canvasState)
    }
    
    func load(using canvasView: CanvasView) {
        _canvasState = CanvasState(canvasView: canvasView)
        _setupWorkflow.run(withState: &_canvasState)
    }
}
