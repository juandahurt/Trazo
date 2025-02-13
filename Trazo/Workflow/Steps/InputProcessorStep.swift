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
        var location = state.inputTouch.location(in: state.canvasView)
        
        // convert to metal coords
        let x = (location.x / state.canvasView.bounds.width) * 2 - 1
        let y = 1 - (location.y / state.canvasView.bounds.height) * 2
        
        location = CGPoint(x: x, y: y).applying(state.ctm.inverted())
        
        state.drawableTouch.positionInTextCoord = .init(x: location.x, y: location.y)
    }
}
