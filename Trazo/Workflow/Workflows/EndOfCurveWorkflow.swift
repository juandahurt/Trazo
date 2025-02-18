//
//  EndOfCurveWorkflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 17/02/25.
//


class EndOfCurveWorkflow: Workflow {
    override init() {
        super.init()
        steps = [
            ClearCurveStep(),
            ClearInputAtributesStep()
        ]
    }
}
