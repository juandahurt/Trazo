//
//  DrawingWorkflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 7/02/25.
//


class DrawingWorkflow: Workflow {
    override init() {
        super.init()
        steps = [
            InputProcessorStep(),
            DrawingStep(),
            CanvasPresentationStep(),
            ClearInputTexturesStep()
        ]
    }
}
