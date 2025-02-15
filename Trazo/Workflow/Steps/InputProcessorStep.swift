//
//  InputProcessorStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import simd
import UIKit

class InputProcessorStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        let center = state.canvasView.center
        var location = state.inputTouch.location(in: state.canvasView)
        location.y = state.canvasView.bounds.height - location.y
        location = location.applying(
            .init(
                translationX: -state.canvasView.bounds.width / 2,
                y: -state.canvasView.bounds.height / 2
            )
        )
        state.drawableTouch.positionInTextCoord = .init(x: location.x, y: location.y)
    }
}
