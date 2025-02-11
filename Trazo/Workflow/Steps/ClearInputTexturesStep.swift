//
//  ClearInputTexturesStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 11/02/25.
//


class ClearInputTexturesStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        print("executing clear input textures")
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: state.grayScaleTexture!),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: state.commandBuffer!
        )
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: state.drawingTexture!),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: state.commandBuffer!
        )
    }
}
