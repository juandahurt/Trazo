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
                    timestamp: $0.timestamp,
                    force: Float($0.force),
                    location: $0.locationRelativeToCenter(ofView: canvasView),
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
        handleDrawing(touch)
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
