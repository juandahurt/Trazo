//
//  CanvasController+PencilGestureDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 22/04/25.
//

import UIKit

extension CanvasController: PencilGestureRecognizerDelegate {
    func didReceiveEstimatedTouches(_ touches: Set<UITouch>) {
        print(touches.count)
    }
}
