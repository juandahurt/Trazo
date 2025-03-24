//
//  CanvasState.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore
import TrazoEngine

/// Holds the current state of the canvas.
struct CanvasState {
    /// Current tranformation matrix.
    var ctm: Mat3x3 = .identity
    var layers: [Layer] = []
    var currentLayerIndex = -1
    
    // textures
    var renderableTexture: Texture?
}
