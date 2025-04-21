//
//  CanvasController+fingerTouch.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 23/03/25.
//

import TrazoCore
import TrazoEngine
import UIKit
import simd

extension CanvasController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        guard let canvasView else { return }
        fingerTouchController.handle(touches.map {
                .init(
                    id: $0.hashValue,
                    location: $0.location(inView: canvasView),
                    phase: $0.phase
                )
            }
        )
    }
}


extension CanvasController: FingerTouchControllerDelegate {
    func didTransformGestureOccur(_ transform: Mat4x4) {
        state.ctm = transform
        canvasView?.setNeedsDisplay()
    }
    
    func didDrawingGestureOccur(withTouch touch: TouchInput) {
        guard let canvasView else { return }
        
        // translate the location relative to the center of the canvas
        let canvasSize = Vector2(
            x: Float(canvasView.bounds.width),
            y: Float(canvasView.bounds.height)
        ) * Float(canvasView.contentScaleFactor)
        var location = touch.location * Float(canvasView.contentScaleFactor)
        location.x -= Float(canvasSize.x) / 2
        location.y -= Float(canvasSize.y) / 2
        location.y *= -1
       
        state.currentAnchorPoints.append(
            .init(
                id: touch.id,
                location: location,
                phase: touch.phase
            )
        )
        
        let drawablePoints = generateDrawablePoints()
        if drawablePoints.isEmpty { return }
        drawGrayscalePoints(drawablePoints)
        colorizeGrayscaleTexture()
        updateDrawingTexture()
        mergeLayers(usingDrawingTexture: true)
        
        canvasView.setNeedsDisplay()
    }
    
    func didDrawingGestureEnd() {
        updateCurrentLayerWithDrawingTexture()
        clearInputTextures()
        clearCurrentStroke()
        
        delegate?
            .didUpdateLayer(
                currentLayer,
                atIndex: state.currentLayerIndex,
                currentLayerIndex: state.currentLayerIndex
            )
    }
}
