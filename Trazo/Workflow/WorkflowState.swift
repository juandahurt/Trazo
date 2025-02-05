//
//  WorkflowState.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import UIKit

struct WorkflowState {
    var scale: Float = 1
    var canvasHasLoaded = false
    var inputTouch = UITouch()
    var convertedtouch = DrawableTouch(
        positionInTextCoord: .zero,
        phase: .cancelled
    )
}
