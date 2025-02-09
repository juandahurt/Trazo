//
//  InputProcessorStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import UIKit

class InputProcessorStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
       print("executing iput processor step")
    }
//    override func excecute(using state: inout DrawingWorkflowState) {
//        let center = _canvasView.center
//        let location = state.inputTouch.location(in: _canvasView)
//        let scaledX = (location.x - center.x) / CGFloat(state.scale) + center.x
//        let scaledY = (location.y - center.y) / CGFloat(state.scale) + center.y
//        let x = (scaledX / _canvasView.bounds.width) * 2 - 1
//        let y = 1 - (scaledY / _canvasView.bounds.height) * 2
//        state.convertedtouch.positionInTextCoord = .init(x: x, y: y)
//        next?.excecute(using: &state)
//    }
}
