//
//  WorkflowStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

protocol WorkflowStep {
    var next: WorkflowStep? { get set }
    func excecute(using data: inout WorkflowState)
}
