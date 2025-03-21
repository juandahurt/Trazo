//
//  CanvasController.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import UIKit

@MainActor
class CanvasController {
    weak var canvasView: CanvasView?
    
    private var state: CanvasState
    private let fingerTouchController = FingerTouchController()
    
    init(state: CanvasState) {
        self.state = state
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
