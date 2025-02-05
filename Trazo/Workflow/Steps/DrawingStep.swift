//
//  DrawingStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

class DrawingStep: WorkflowStep {
    let painter: Painter
    var next: (any WorkflowStep)?

    init(painter: Painter) {
        self.painter = painter
    }
    
    func excecute(using data: inout WorkflowState) {
        if !data.canvasHasLoaded {
            data.canvasHasLoaded = true
            painter.present(scale: data.scale)
            painter.resetCommandBuffer()
            return
        }
        
        painter.draw(fingerTouches: [data.convertedtouch])
        painter.clearTextures()
        painter.present(scale: data.scale)
        painter.resetCommandBuffer()
    }
}
