//
//  BlankCanvasTextureStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 10/02/25.
//


class BlankCanvasTextureStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        state.commandBuffer?.pushDebugGroup("blank bakcground texture")
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: state.backgroundTexture!),
            with: (1, 1, 1, 1),
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
    }
}
