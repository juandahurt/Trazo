//
//  TransformCanvasStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 11/02/25.
//


class TransformCanvasStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        state.canvasView.transform = state.canvasView.transform.scaledBy(
            x: state.transformScale,
            y: state.transformScale
        )
        // make sure the background is cleared on the presetation step
        state.canvasBackgroundColor = (0.125, 0.125, 0.125, 1)
    }
}
