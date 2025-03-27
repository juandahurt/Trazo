//
//  CanvasController+fingerTouch.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 23/03/25.
//

import TrazoCore
import TrazoEngine
import UIKit

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

    func didTransfromGestureEnd() {
       // TODO: update ctm
    }
    
    func didDrawingGestureOccur(withTouch touch: TouchInput) {
        guard let canvasView else { return }
        
        let canvasSzie = canvasView.bounds
        var location = touch.location
        location.x -= Float(canvasSzie.width) / 2
        location.y -= Float(canvasSzie.height) / 2
        location.y *= -1
        
        drawGrayscalePoints([location])
        colorizeGrayscaleTexture()
        updateDrawingTexture()
        mergeLayers(usingDrawingTexture: true)
        
        canvasView.setNeedsDisplay()
    }
    
    func didDrawingGestureEnd() {
        clearInputTextures()
    }
}
