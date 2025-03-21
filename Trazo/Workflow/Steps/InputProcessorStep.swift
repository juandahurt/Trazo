//
//  InputProcessorStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import TrazoCore
import UIKit

class InputProcessorStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        guard let touch = state.inputTouch else { return }
        var location = CGPoint(x: CGFloat(touch.location.x), y: CGFloat(touch.location.y))
        location.y = state.canvasView.bounds.height - location.y
        location = location.applying(
            .init(
                translationX: -state.canvasView.bounds.width / 2,
                y: -state.canvasView.bounds.height / 2
            )
        )
//        let touchPoint = CGPoint(Float(location.x), Float(location.y))
//        state.currentCurve.addPoint(touchPoint)
    }
}
