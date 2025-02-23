//
//  ClearInputAtributesStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 11/02/25.
//


class ClearInputAtributesStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        state.commandBuffer?.pushDebugGroup("clear input textures")
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: state.grayScaleTexture!),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: state.commandBuffer!
        )
        Renderer.instance.merge(
            state.strokeTexture!,
            to: state.layerTexture!,
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
    }
}
