//
//  TransformCanvasStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 11/02/25.
//

import CoreGraphics

class TransformCanvasStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        print("transform canvas step")
       
        state.ctm = state.ctm
            .rotated(by: -state.rotation)
            .scaledBy(x: state.scale, y: state.scale)
            
        // make sure the background is cleared on the presetation step
        state.canvasBackgroundColor = (0.125, 0.125, 0.125, 1)
    }
}
