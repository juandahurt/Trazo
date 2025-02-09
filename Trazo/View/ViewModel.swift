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

struct CanvasState {
    var canvasView: CanvasView
    var inputTouch: UITouch = UITouch()
    
    init(canvasView: CanvasView) {
        self.canvasView = canvasView
    }
}

class ViewModel {
    private var _canvasState: CanvasState?
    private var _drawingWorkflow = DrawingWorkflow()
//    private var _transformWorkflow: TransformDrawingWorkflow?
//    private var _workflow: WorkflowStep?
//    private var _workflowState = WorkflowState()
   
    func scaleUpdated(newValue scale: CGFloat) {
        // TODO: fix issue where canvas keeps drawing the last point
//        _workflowState.scale *= Float(scale)
//        _workflow?.excecute(using: &_workflowState)
    }
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        guard var _canvasState else { return }
//        guard let _workflow else { return }
        // TODO: check what I need to do when usser uses more than one finger
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        _canvasState.inputTouch = touch
        
        _drawingWorkflow.run(withState: &_canvasState)
    }
    
    func load(using canvasView: CanvasView) {
        _canvasState = CanvasState(canvasView: canvasView)
//        _drawingWorkflow = .init(canvasView: canvasView)
//        let inputProcessor = InputProcessorStep(canvasView: canvasView)
//        _workflow = inputProcessor
//        
//        let drawingStep = DrawingStep(
//            painter: Painter(canvasView: canvasView)
//        )
//        inputProcessor.next = drawingStep
//        
//        // execute the workflow so the canvas is presented for the first time
//        _workflow?.excecute(using: &_workflowState)
    }
}
