//
//  Workflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import UIKit

class Workflow {
    var steps: [WorkflowStep] = []
    
    func run(withState state: inout CanvasState) {
        for step in steps {
            step.excecute(using: &state)
        }
    }
}
