//
//  CanvasPresentationStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 9/02/25.
//

class CanvasPresentationStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        state.commandBuffer?.pushDebugGroup("merge background texture with layer texture")
        Renderer.instance.merge(
            state.layerTexture!,
            with: state.backgroundTexture!,
            on: state.canvasTexture!.actualTexture,
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
        
        Renderer.instance.drawTexture(
            texture: state.canvasTexture!,
            on: state.canvasView.currentDrawable!.texture,
            using: state.commandBuffer!,
            backgroundColor: state.canvasBackgroundColor,
            ctm: state.ctm
        )
        Renderer.instance.fillTexture(
            texture: state.canvasTexture!,
            with: (r: 0, g: 0, b: 0, a: 0),
            using: state.commandBuffer!
        )
        
        state.commandBuffer?.present(state.canvasView.currentDrawable!)
        state.commandBuffer?.commit()
        state.commandBuffer?.waitUntilCompleted()
        
        _resetCommandBuffer(currentState: &state)
        
        state.canvasView.setNeedsDisplay()
    }
    
    private func _resetCommandBuffer(currentState state: inout CanvasState) {
        state.commandBuffer = Metal.commandQueue.makeCommandBuffer()
    }
}
