//
//  FingerTouchController.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore
import simd

@MainActor
protocol FingerTouchControllerDelegate: AnyObject {
    /// Notifies the delegate that a transform gesture has occurred.
    /// - Parameter transform: The generated transformation.
    func didTransformGestureOccur(_ transform: Mat4x4)
    /// Notifies the delegate that a drawing gesture has occurred.
    /// - Parameter touch: Input touch.
    func didDrawingGestureOccur(withTouch touch: TouchInput)
    /// Notifes the delegate that a drawing gesture ended.
    func didDrawingGestureEnd()
}

/// It manages the touches that the user makes with their finger.
@MainActor
class FingerTouchController {
    private enum FingerGestureType {
        case draw, transform, unknown
    }
    /// It holds the touches of the current gesture.
    private var touchStore = FingerInputStore()
    
    /// Transforms the canvas
    private let transformer = Transformer()
    private var currentTransform: Mat4x4 = .identity
   
    private var currentGestureType: FingerGestureType = .unknown
    
    weak var delegate: FingerTouchControllerDelegate?
    
    private var hasUserLiftedFingers: Bool {
        touchStore.touchesDict.keys
            .reduce(
                true,
                { $0 && (touchStore.touchesDict[$1]?.last?.phase == .ended || touchStore.touchesDict[$1]?.last?.phase == .cancelled)
                })
    }
    
    private func getEstimatedGestureType() -> FingerGestureType {
        let numberOfTouches = touchStore.numberOfTouches
        switch numberOfTouches {
        case 1: return .draw
        case 2: return .transform
        default: return .unknown
        }
    }
    
    func handle(_ touches: [TouchInput]) {
        // first, we store the touches
        touchStore.save(touches)
        
        let estimatedGestureType = getEstimatedGestureType()
        switch estimatedGestureType {
        case .draw:
            if currentGestureType == .transform {
                currentGestureType = .unknown
            } else {
                currentGestureType = .draw
            }
        case .transform:
            if currentGestureType != .transform {
                if currentGestureType == .draw { delegate?.didDrawingGestureEnd() }
                transformer.reset()
            }
            currentGestureType = .transform
        case .unknown:
            currentGestureType = estimatedGestureType
        }
        
        switch currentGestureType {
        case .draw:
            // notify delegate of this new drawing touch
            if let touch = touches.first {
                delegate?.didDrawingGestureOccur(withTouch: touch)
            }
            if hasUserLiftedFingers {
                delegate?.didDrawingGestureEnd()
            }
        case .transform:
            if !transformer.isInitialized {
                transformer.initialize(withTouches: touchStore.touchesDict)
            }
            if !hasUserLiftedFingers {
                transformer.transform(usingCurrentTouches: touchStore.touchesDict)
                delegate?.didTransformGestureOccur(transformer.transform)
            }
        case .unknown: break
        }
        
        if hasUserLiftedFingers {
            currentGestureType = .unknown
        }
        
        // check if the touches need to be removed (aka. the touch has finished)
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled {
                touchStore.removeTouch(identifiedBy: touch.id)
            }
        }
    }
}
