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
            withColor: state.selectedColor,
            on: state.strokeTexture!,
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
        
        state.commandBuffer?.pushDebugGroup("merge drawing texture with stroke texture")
        Renderer.instance.merge(
            state.strokeTexture!,
            with: state.layerTexture!,
            on: state.drawingTexture!,
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
    }
}

