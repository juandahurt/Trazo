//
//  TransformCanvasStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 11/02/25.
//

import CoreGraphics

class TransformCanvasStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        let transform: CGAffineTransform =
            .identity
            .translatedBy(x: state.translation.x, y: -state.translation.y)
            .rotated(by: -state.rotation)
            .scaledBy(x: state.scale, y: state.scale)
        
        state.ctm = transform
    }
}
