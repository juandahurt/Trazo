//
//  CanvasController+Rendering.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 25/03/25.
//

import TrazoCore
import TrazoEngine

extension CanvasController {
    func updateCurrentLayerWithDrawingTexture() {
        TrazoEngine.merge(
            texture: state.drawingTexture,
            with: currentLayer.texture,
            on: currentLayer.texture
        )
    }
    
    func mergeLayers(usingDrawingTexture: Bool) {
        TrazoEngine.pushDebugGroup("Merge layers")
        for index in stride(from: state.layers.count - 1, to: -1, by: -1) {
            var layerTexture = state.layers[index].texture
            if index == state.currentLayerIndex && usingDrawingTexture {
                layerTexture = state.drawingTexture
            }
            TrazoEngine.merge(
                texture: layerTexture,
                with: state.renderableTexture!,
                on: state.renderableTexture!
            )
        }
        TrazoEngine.popDebugGroup()
    }
    
    func clearInputTextures() {
        TrazoEngine.pushDebugGroup("Clear input textures")
        TrazoEngine.fillTexture(
            state.grayscaleTexture,
            withColor: [0, 0, 0, 0]
        )
        TrazoEngine.fillTexture(
            state.drawingTexture,
            withColor: [0, 0, 0, 0]
        )
        TrazoEngine.popDebugGroup()
    }
    
    func updateDrawingTexture() {
        TrazoEngine.pushDebugGroup("Update drawing texture")
        TrazoEngine.merge(
            texture: state.strokeTexture,
            with: currentLayer.texture,
            on: state.drawingTexture
        )
        TrazoEngine.popDebugGroup()
    }
    
    func colorizeGrayscaleTexture() {
        TrazoEngine.pushDebugGroup("Colorize grayscale texture")
        TrazoEngine.colorize(
            grayscaleTexture: state.grayscaleTexture,
            withColor: state.color,
            on: state.strokeTexture
        )
        TrazoEngine.popDebugGroup()
    }
    
    func drawGrayscalePoints(_ points: [Vector2]) {
        TrazoEngine.pushDebugGroup("Draw grayscale points")
        TrazoEngine.drawGrayscalePoints(
                points,
                size: 10,
                transform: state.ctm.inverse,
                on: state.grayscaleTexture
            )
        TrazoEngine.popDebugGroup()
    }
}
