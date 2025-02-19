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
       
        state.commandBuffer?.pushDebugGroup("colorization")
        // colorization
        Renderer.instance.colorize(
            grayscaleTexture: state.grayScaleTexture!,
            withColor: (1, 0, 0, 1),
            on: state.drawingTexture!,
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
        
        state.commandBuffer?.pushDebugGroup("merge drawing texture with layer texture")
        Renderer.instance.merge(
            state.drawingTexture!,
            to: state.layerTexture!,
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
    }
}

