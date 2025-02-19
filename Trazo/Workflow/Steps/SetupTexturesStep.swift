//
//  SetupTexturesStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 10/02/25.
//


class SetupTexturesStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        let canvasView = state.canvasView
        state.canvasTexture = TextureManager().createDrawableTexture(
            ofSize: canvasView.bounds
        )
        state.drawingTexture = TextureManager().createMetalTexture(
            ofSize: canvasView.bounds
        )
        state.grayScaleTexture = TextureManager().createMetalTexture(
            ofSize: canvasView.bounds
        )
        state.backgroundTexture = TextureManager().createMetalTexture(
            ofSize: canvasView.bounds
        )
        state.layerTexture = TextureManager().createMetalTexture(
            ofSize: canvasView.bounds
        )
    }
}
