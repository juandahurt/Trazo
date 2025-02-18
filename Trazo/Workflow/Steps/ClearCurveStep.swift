//
//  ClearCurveStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 17/02/25.
//


class ClearCurveStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        state.currentCurve = .init()
    }
}
