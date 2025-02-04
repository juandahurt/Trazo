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
    private var _workflow: WorkflowStep?
    private var _workflowState = WorkflowState()
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        guard let _workflow else { return }
        // TODO: check what I need to do when usser uses more than one finger
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        _workflowState.inputTouch = touch
        _workflow.excecute(using: &_workflowState)
    }
    
    func loadCanvas(using canvasView: CanvasView) {
        let inputProcessor = InputProcessorStep(canvasView: canvasView)
        _workflow = inputProcessor
        
        let drawingStep = DrawingStep(
            painter: Painter(canvasView: canvasView)
        )
        inputProcessor.next = drawingStep
        
        // execute the workflow so the canvas is presented for the first time
        _workflow?.excecute(using: &_workflowState)
    }
}
