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
        let center = state.canvasView.center
        let location = state.inputTouch.location(in: state.canvasView)
        let scaledX = (location.x - center.x) / CGFloat(state.scale) + center.x
        let scaledY = (location.y - center.y) / CGFloat(state.scale) + center.y
        let x = (scaledX / state.canvasView.bounds.width) * 2 - 1
        let y = 1 - (scaledY / state.canvasView.bounds.height) * 2
        state.drawableTouch.positionInTextCoord = .init(x: x, y: y)
    }
}
