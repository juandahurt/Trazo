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
}


extension CanvasController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        print(touches.count)
    }
}
