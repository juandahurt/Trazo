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
        let center = _canvasView.center
        let location = data.inputTouch.location(in: _canvasView)
        let scaledX = (location.x - center.x) / CGFloat(data.scale) + center.x
        let scaledY = (location.y - center.y) / CGFloat(data.scale) + center.y
        let x = (scaledX / _canvasView.bounds.width) * 2 - 1
        let y = 1 - (scaledY / _canvasView.bounds.height) * 2
        data.convertedtouch.positionInTextCoord = .init(x: x, y: y)
        next?.excecute(using: &data)
    }
}
