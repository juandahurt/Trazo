//
//  FingerTouchController.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore

@MainActor
protocol FingerTouchControllerDelegate: AnyObject {
    /// Notifies the delegate that a transform gesture has occurred.
    /// - Parameter transform: The generated transformation.
    func didTransformGestureOccur(_ transform: Mat3x3)
    /// Notifies the delegate that a transform gesture has ended.
    func didTransfromGestureEnd()
}

/// It manages the touches that the user makes with their finger.
@MainActor
class FingerTouchController {
    /// It holds the touches of the current gesture.
    private var touchStore = FingerInputStore()
    
    /// Transforms the canvas
    private let transformer = Transformer()
    
    weak var delegate: FingerTouchControllerDelegate?
    
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
    
    func handle(_ touches: [TouchInput]) {
        // first, we store the touches
        touchStore.save(touches)

        // then, we check which kind of action the user is trying to do
        if isUserTransforming {
            if !transformer.isInitialized {
                transformer.initialize(withTouches: touchStore.touchesDict)
            }
            if !hasUserLiftedFingers {
                if let matrix = transformer.tranform(
                    usingCurrentTouches: touchStore.touchesDict
                ) {
                    delegate?.didTransformGestureOccur(matrix)
                }
            } else {
                transformer.reset()
            }
        } else {
            // TODO: draw
//            transformer.reset()
        }
        
//        if isUserDrawing {
//            if let touch = touches.first {
//                onDrawIntent?(touch)
//            }
//            if hasUserLiftedFingers {
//                onDrawFinished?()
//            }
//        }
        // check if the touches need to be removed (aka. the touch has finished)
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled {
                touchStore.removeTouch(identifiedBy: touch.id)
            }
        }
    }
}
