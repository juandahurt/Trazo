//
//  CanvasController+PencilGestureDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 22/04/25.
//

import UIKit
import TrazoEngine

extension CanvasController: PencilGestureRecognizerDelegate {
    func didReceiveActualTouches(_ touches: Set<UITouch>) {
        guard
            let uiTouch = touches.first,
            let estimationUpdateIndex = uiTouch.estimationUpdateIndex,
            let index = state.currentEstimatedTouchInput[estimationUpdateIndex]
        else {
            return
        }
       
        // update with the actual value
        state.currentTouchInputs[index].force = Float(uiTouch.force)
        state.currentEstimatedTouchInput.removeValue(forKey: estimationUpdateIndex)
        
        // update the points affected
        let sizeCalculator = PointSizeCalculator()
        
        // update left segment
        if index > 0 && !state.currentDrawableSegments.isEmpty {
            sizeCalculator.updateSizes(
                ofPoints: &state.currentDrawableSegments[index - 1].points,
                pointCount: state.currentDrawableSegments[index - 1].pointsCount,
                v0: state.currentTouchInputs[index - 1].force * state.brushSize,
                v1: state.currentTouchInputs[index].force * state.brushSize
            )
        }
        
        // update right segment
        if index < state.currentDrawableSegmentCount {
            sizeCalculator.updateSizes(
                ofPoints: &state.currentDrawableSegments[index].points,
                pointCount: state.currentDrawableSegments[index].pointsCount,
                v0: state.currentTouchInputs[index].force * state.brushSize,
                v1: state.currentTouchInputs[index + 1].force * state.brushSize
            )
        }
        
        // draw
        let points: [DrawablePoint] = state.currentDrawableSegments.reduce(
            [],
            { $0 + $1.points }
        )
        draw(
            points: points,
            numPoints: state.currentDrawablePointCount,
            clearGrayscaleTexture: true
        )
    }

    func didReceiveEstimatedTouches(_ touches: Set<UITouch>) {
        guard let canvasView else { return }
        guard let uiTouch = touches.first else { return }
        
        let touch = TouchInput(
            id: uiTouch.hashValue,
            timestamp: uiTouch.timestamp,
            estimationUpdateIndex: uiTouch.estimationUpdateIndex,
            estimatedProperties: uiTouch.estimatedProperties,
            force: Float(uiTouch.force),
            location: uiTouch.locationRelativeToCenter(ofView: canvasView),
            phase: uiTouch.phase
        )
        
        // TODO: clear current stroke when all of the estimated touches have been updated and
        // TODO: we have received the last of the touches, aka. phase == .ended || .canceled
        if touch.phase == .began {
            updateCurrentLayerWithDrawingTexture()
            clearInputTextures()
            clearCurrentStroke()
            state.currentEstimatedTouchInput.removeAll()
        }
        
        handleDrawing(touch, ignoringForce: false)
    
        guard
            let estimatedProperties = touch.estimatedProperties,
            estimatedProperties.contains(.force),
            let estimationUpdateIndex = touch.estimationUpdateIndex
        else { return }
     
        // store estimated touch input
        let touchInputIndex = state.currentTouchInputCount - 1
        state.currentEstimatedTouchInput[estimationUpdateIndex] = touchInputIndex
    }
}

