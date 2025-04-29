//
//  CanvasController+PencilGestureDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 22/04/25.
//

import UIKit

extension CanvasController: PencilGestureRecognizerDelegate {
    func didReceiveActualTouches(_ touches: Set<UITouch>) {
        // TODO: implement
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
       
        // TODO: clear current stroke when drawing using a finger after drawing with pencil
        if touch.phase == .began {
            clearCurrentStroke()
        }
        
        handleDrawing(touch)
    }
}

