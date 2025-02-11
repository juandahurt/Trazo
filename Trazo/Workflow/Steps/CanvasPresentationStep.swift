//
//  CanvasPresentationStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 9/02/25.
//

class CanvasPresentationStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        print("executing canvas presentation step")
        Renderer.instance.drawTexture(
            texture: state.canvasTexture!,
            on: state.canvasView.currentDrawable!.texture,
            using: state.commandBuffer!,
            backgroundColor: state.canvasBackgroundColor,
            scale: Float(state.scale)
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
