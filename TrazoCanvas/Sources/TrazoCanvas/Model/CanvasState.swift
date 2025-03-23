//
//  CanvasState.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore

/// Holds the current state of the canvas.
struct CanvasState {
    /// Current tranformation matrix.
    var ctm: Mat3x3 = .identity
    var layers: [Layer] = []
}
