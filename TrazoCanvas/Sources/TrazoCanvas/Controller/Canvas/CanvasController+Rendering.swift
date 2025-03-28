//
//  CanvasController+Rendering.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 25/03/25.
//

import TrazoCore
import TrazoEngine

extension CanvasController {
    func clearCurrentStroke() {
        state.currentStroke = []
        state.currentAnchorPoints = []
    }
    
    func updateCurrentLayerWithDrawingTexture() {
        TrazoEngine.pushDebugGroup("Update current layer with stroke texture")
        TrazoEngine.merge(
            texture: state.strokeTexture,
            with: currentLayer.texture,
            on: currentLayer.texture
        )
        TrazoEngine.popDebugGroup()
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
            withColor: state.brushColor,
            on: state.strokeTexture
        )
        TrazoEngine.popDebugGroup()
    }
    
    func drawGrayscalePoints(_ points: [DrawablePoint]) {
        TrazoEngine.pushDebugGroup("Draw grayscale points")
        TrazoEngine.drawGrayscalePoints(
            points.map { $0.position },
            size: 10,
            transform: state.ctm.inverse,
            on: state.grayscaleTexture
        )
        TrazoEngine.popDebugGroup()
    }
    
    func generateDrawablePoints() -> [DrawablePoint] {
        let numAnchorPoints = state.currentAnchorPoints.count
        guard numAnchorPoints > 3 else { return [] }
        
        let i = numAnchorPoints - 3
        
        return CatmullRom().generateDrawablePoints(
            anchorPoints: .init(
                p0: state.currentAnchorPoints[i - 1].location,
                p1: state.currentAnchorPoints[i].location,
                p2: state.currentAnchorPoints[i + 1].location,
                p3: state.currentAnchorPoints[i + 2].location
            ),
            scale: state.ctm.scale.x // since the scale should be the same on any axis
        )
    }
}
