//
//  SetupCanvasWorkflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 10/02/25.
//


class SetupCanvasWorkflow: Workflow {
    override init() {
        super.init()
        steps = [
            SetupTexturesStep(),
            BlankCanvasTextureStep(),
            CanvasPresentationStep()
        ]
    }
}
