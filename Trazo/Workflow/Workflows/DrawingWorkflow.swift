//
//  DrawingWorkflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 7/02/25.
//

import CoreGraphics



class DrawingWorkflow: Workflow {
    override init() {
        super.init()
        steps = [
            InputProcessorStep(),
            CurveFittingStep(),
            DrawGrayPointsStep(),
            DrawingStep(),
            CanvasPresentationStep()
        ]
    }
}
