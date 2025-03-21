//
//  FingerTouchesOrchestator.swift
//  Trazo
//
//  Created by Juan Hurtado on 18/03/25.
//

import CoreGraphics

/// It holds and manages the touches that the user makes.
class FingerTouchesOrchestator {
    /// It holds the touches of the current gesture.
    let touchStore = FingerTouchStore()
    /// Transforms the canvas, given the current touches.
    let transformer = CanvasTransformer()
   
    var onTransformChange: ((CGAffineTransform) -> Void)?
    var onDrawIntent: ((Touch) -> Void)?
    var onDrawFinished: (() -> Void)?
    
    private var isUserTransforming: Bool {
        touchStore.numberOfTouches == 2
    }
    
    private var isUserDrawing: Bool {
        touchStore.numberOfTouches == 1
    }
    
    private var hasUserLiftedFingers: Bool {
        touchStore.touchesDict.keys
            .reduce(
                true,
                { $0 && (touchStore.touchesDict[$1]?.last?.phase == .ended || touchStore.touchesDict[$1]?.last?.phase == .cancelled)
                })
    }
    
    func receivedTouches(_ touches: [Touch]) {
        // first, we store the touches
        touchStore.save(touches)
        
        // then, we check which kind of action the user is trying to do
        if isUserTransforming {
            if !transformer.isInitialized {
                transformer.initialize(withTouches: touchStore.touchesDict)
            }
            if !hasUserLiftedFingers {
                if let matrix = transformer.tranform(
                    usingCurrentTouches: touchStore.touchesDict,
                    canvasCenter: .init(1640 / 2, 2360 / 2)
                ) {
                    onTransformChange?(matrix)
                }
            } else {
                transformer.reset()
                
            }
        } else {
            // TODO: draw
            transformer.reset()
        }
        
        if isUserDrawing {
            if let touch = touches.first {
                onDrawIntent?(touch)
            }
            if hasUserLiftedFingers {
                onDrawFinished?()
            }
        }
        // check if the touches need to be removed (aka. the touch has finished)
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled {
                touchStore.removeTouch(byID: touch.id)
            }
        }
    }
}
