//
//  DrawingStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import simd
import CoreGraphics

class DrawingStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        
        // colorization
        Renderer.instance.colorize(
            grayscaleTexture: state.grayScaleTexture!,
            withColor: (1, 0, 0, 0.5),
            on: state.drawingTexture!,
            using: state.commandBuffer!
        )
        
        // merge drawing texture with the canvas texture
        Renderer.instance.merge(
            state.drawingTexture!,
            to: state.canvasTexture!.actualTexture,
            using: state.commandBuffer!
        )
    }
}

