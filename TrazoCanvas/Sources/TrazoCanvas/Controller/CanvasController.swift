//
//  CanvasController.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore
import UIKit

@MainActor
class CanvasController {
    weak var canvasView: CanvasView?
    
    private var state: CanvasState
    private let fingerTouchController = FingerTouchController()
    
    init(state: CanvasState) {
        self.state = state
        
        fingerTouchController.delegate = self
    }
}

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
    func didTransformGestureOccur(_ transform: Mat3x3) {
        // TODO: update canvas using the transform
        debugPrint(transform)
    }

    func didTransfromGestureEnd() {
       // TODO: update ctm
    }
}
