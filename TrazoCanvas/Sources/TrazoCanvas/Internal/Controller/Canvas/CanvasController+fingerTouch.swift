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
        state.currentAnchorPoints.append(touch)
        
        switch touch.phase {
        case .moved:
            // if we have thre points, we need to draw the initial part of the curve
            if state.currentAnchorPoints.count == 3 {
                let drawablePoints = generateInitialDrawablePoints()
                draw(points: drawablePoints)
                return
            }
            let drawablePoints = generateMidDrawablePoints()
            draw(points: drawablePoints)
        case .ended:
            // when the gesture ends, we need to draw the end of the curve
            let drawablePoints = generateLastDrawablePoints()
            draw(points: drawablePoints)
        default: break
        }
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
