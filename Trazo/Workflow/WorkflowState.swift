//
//  WorkflowState.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import UIKit

struct WorkflowState {
    var canvasHasLoaded = false
    var inputTouch = UITouch()
    var convertedtouch = DrawableTouch(
        positionInTextCoord: .zero,
        phase: .cancelled
    )
}
