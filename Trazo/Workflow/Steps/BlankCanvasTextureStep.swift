//
//  BlankCanvasTextureStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 10/02/25.
//


class BlankCanvasTextureStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        Renderer.instance.fillTexture(
            texture: state.canvasTexture!,
            with: (1, 1, 1, 1),
            using: state.commandBuffer!
        )
    }
}
