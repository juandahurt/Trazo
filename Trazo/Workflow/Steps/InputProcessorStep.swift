//
//  InputProcessorStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import UIKit

class InputProcessorStep: WorkflowStep {
    private let _canvasView: UIView
    var next: (any WorkflowStep)?
    
    init(canvasView: UIView) {
        _canvasView = canvasView
    }
    
    func excecute(using data: inout WorkflowState) {
        let location = data.inputTouch.location(in: _canvasView)
        let x = (location.x / _canvasView.bounds.width) * 2 - 1
        let y = 1 - (location.y / _canvasView.bounds.height) * 2
        data.convertedtouch.positionInTextCoord = .init(x: x, y: y)
        next?.excecute(using: &data)
    }
}
