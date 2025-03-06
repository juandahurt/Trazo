//
//  TransformCanvasWorkflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/02/25.
//


class TransformCanvasWorkflow: Workflow {
    override init() {
        super.init()
        steps = [
            TransformCanvasStep(),
            CanvasPresentationStep(),
            ClearCurveStep()
        ]
    }
}
