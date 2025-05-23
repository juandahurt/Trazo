//
//  CanvasController+Rendering.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 25/03/25.
//

import TrazoCore
import TrazoEngine
import simd
import Foundation

extension CanvasController {
    func clearCurrentStroke() {
        state.currentDrawableSegments = []
        state.currentTouchInputs = []
        state.currentTouchInputCount = 0
        state.currentDrawablePointCount = 0
        state.currentDrawableSegmentCount = 0
        state.currentEstimatedTouchInput = [:]
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
    
    func drawGrayscalePoints(
        _ points: [DrawablePoint],
        numPoints: Int,
        clearBackground: Bool
    ) {
        TrazoEngine.pushDebugGroup("Draw grayscale points")
        TrazoEngine.drawGrayscalePoints(
            points,
            numPoints: numPoints,
            withOpacity: state.brushOpacity,
            transform: state.ctm.inverse,
            projection: state.cpm,
            on: state.grayscaleTexture,
            clearingBackground: clearBackground
        )
        TrazoEngine.popDebugGroup()
    }
   
    func generateInitalSegment(ignoringForce: Bool) -> DrawableSegment {
        guard state.currentTouchInputCount > 3 else { return .empty }
        
        // extend anchor points following the direction from the second to the first one
        let i = 0
        let first = state.currentTouchInputs[i]
        let second = state.currentTouchInputs[i + 1]
        let third = state.currentTouchInputs[i + 2].location
        
        let dir = normalize(first.location - second.location)
        
        let dist: Float = 5.0 // let's just say the new point will be located at 5 points
                              // from the last one
        let new = first.location + (dir * dist)
        
        return CatmullRom()
            .generateDrawableSegment(
                anchorPoints: .init(
                    p0: new,
                    p1: (location: first.location, force: first.force),
                    p2: (location: second.location, force: first.force),
                    p3: third
                ),
                scale: state.ctm.scale.x,
                brushSize: state.brushSize,
                ignoreForce: ignoringForce
            )
    }
    
    func generateMidDrawableSegment(ignoringForce: Bool) -> DrawableSegment {
        guard state.currentTouchInputCount > 3 else { return .empty }
        
        let i = state.currentTouchInputCount - 3
        
        let p1 = state.currentTouchInputs[i]
        let p2 = state.currentTouchInputs[i + 1]
        
        return CatmullRom().generateDrawableSegment(
            anchorPoints: .init(
                p0: state.currentTouchInputs[i - 1].location,
                p1: (location: p1.location, force: p1.force),
                p2: (location: p2.location, force: p2.force),
                p3: state.currentTouchInputs[i + 2].location
            ),
            scale: state.ctm.scale.x, // since the scale should be the same on any axis
            brushSize: state.brushSize,
            ignoreForce: ignoringForce
        )
    }
   
    func generateLastDrawableSegment(ignoringForce: Bool) -> DrawableSegment {
        guard state.currentTouchInputCount > 3 else { return .empty }
        
        // extend anchor points following the same direction
        let i = state.currentTouchInputs.count - 1
        let beforeBeforeLast = state.currentTouchInputs[i - 2].location
        let beforeLast = state.currentTouchInputs[i - 1]
        let last = state.currentTouchInputs[i]
        
        let dir = normalize(last.location - beforeLast.location)
        
        let dist: Float = 5.0 // let's just say the new point will be located at 5 points
                              // from the last one
        let new = last.location + (dir * dist)
        
        return CatmullRom()
            .generateDrawableSegment(
                anchorPoints: .init(
                    p0: beforeBeforeLast,
                    p1: (location: beforeLast.location, force: beforeLast.force),
                    p2: (location: last.location, force: last.force),
                    p3: new
                ),
                scale: state.ctm.scale.x,
                brushSize: state.brushSize,
                ignoreForce: ignoringForce
            )
    }
   
    func handleDrawing(_ touch: TouchInput, ignoringForce: Bool) {
        if touch.phase == .began && !state.currentTouchInputs.isEmpty {
            updateCurrentLayerWithDrawingTexture()
            clearInputTextures()
            clearCurrentStroke()
        }
        
        state.currentTouchInputs.append(touch)
        state.currentTouchInputCount += 1
        
        switch touch.phase {
        case .moved:
            // if we have thre points, we need to draw the initial part of the curve
            if state.currentTouchInputCount == 3 {
                let segment = generateInitalSegment(
                    ignoringForce: ignoringForce
                )
                draw(
                    points: segment.points,
                    numPoints: segment.pointsCount,
                    clearGrayscaleTexture: false
                )
                state.currentDrawableSegments.append(segment)
                state.currentDrawableSegmentCount += 1
                state.currentDrawablePointCount += segment.pointsCount
            } else if state.currentTouchInputCount > 3 {
                let segment = generateMidDrawableSegment(ignoringForce: ignoringForce)
                draw(
                    points: segment.points,
                    numPoints: segment.pointsCount,
                    clearGrayscaleTexture: false
                )
                state.currentDrawableSegments.append(segment)
                state.currentDrawableSegmentCount += 1
                state.currentDrawablePointCount += segment.pointsCount
            }
        case .ended, .cancelled:
            // on the last input, we need to draw the missing segment
            // plus the last segment
            let segment = generateMidDrawableSegment(ignoringForce: ignoringForce)
            draw(
                points: segment.points,
                numPoints: segment.pointsCount,
                clearGrayscaleTexture: false
            )
            state.currentDrawableSegments.append(segment)
            state.currentDrawableSegmentCount += 1
            state.currentDrawablePointCount += segment.pointsCount
            
            let lastSegment = generateLastDrawableSegment(ignoringForce: ignoringForce)
            draw(
                points: lastSegment.points,
                numPoints: lastSegment.pointsCount,
                clearGrayscaleTexture: false
            )
            state.currentDrawableSegments.append(lastSegment)
            state.currentDrawableSegmentCount += 1
            state.currentDrawablePointCount += lastSegment.pointsCount
        default: break
        }
    }
    
    func draw(points: [DrawablePoint], numPoints: Int, clearGrayscaleTexture: Bool) {
        guard !points.isEmpty else { return }
        
        drawGrayscalePoints(
            points,
            numPoints: numPoints,
            clearBackground: clearGrayscaleTexture
        )
        colorizeGrayscaleTexture()
        updateDrawingTexture()
        mergeLayers(usingDrawingTexture: true)
        
        canvasView?.setNeedsDisplay()
    }
}
