//
//  CanvasController+Rendering.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 25/03/25.
//

import TrazoCore
import TrazoEngine
import simd

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
            if !state.layers[index].isVisible { continue }
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
        TrazoEngine.fillTexture(
            state.strokeTexture,
            withColor: [0, 0, 0, 0]
        )
        TrazoEngine.popDebugGroup()
    }
    
    func clearRenderableTexture() {
        TrazoEngine.pushDebugGroup("Clear renderable texture")
        TrazoEngine.fillTexture(
            state.renderableTexture,
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
            size: state.brushSize,
            transform: state.ctm.inverse,
            projection: state.cpm,
            on: state.grayscaleTexture
        )
        TrazoEngine.popDebugGroup()
    }
    
    func generateMidDrawablePoints() -> [DrawablePoint] {
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
   
    func generateLastDrawablePoints() -> [DrawablePoint] {
        let numAnchorPoints = state.currentAnchorPoints.count
        guard numAnchorPoints > 3 else { return [] }
        
        // extend anchor points following the same direction
        let i = state.currentAnchorPoints.count - 2
        let beforeBeforeLast = state.currentAnchorPoints[i - 2].location
        let beforeLast = state.currentAnchorPoints[i - 1].location
        let last = state.currentAnchorPoints[i].location
        
        let dir = normalize(last - beforeLast)
        
        let dist: Float = 5.0 // let's just say the new point will be located at 5 points
                              // from the last one
        let new = last + (dir * dist)
        
        return CatmullRom()
            .generateDrawablePoints(
                anchorPoints: .init(
                    p0: beforeBeforeLast,
                    p1: beforeLast,
                    p2: last,
                    p3: new
                ),
                scale: state.ctm.scale.x
            )
    }
    
    func draw(points: [DrawablePoint]) {
        guard !points.isEmpty else { return }
        
        drawGrayscalePoints(points)
        colorizeGrayscaleTexture()
        updateDrawingTexture()
        mergeLayers(usingDrawingTexture: true)
        
        canvasView?.setNeedsDisplay()
    }
}
