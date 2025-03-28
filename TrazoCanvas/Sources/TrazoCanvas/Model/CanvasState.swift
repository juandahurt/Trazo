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
    var ctm: Mat4x4 = .identity
    
    // MARK: Layers
    var layers: [Layer] = []
    /// Current layer index.
    var currentLayerIndex = -1
   
    var currentAnchorPoints: [TouchInput] = []
    var currentStroke: [DrawablePoint] = []
    
    // MARK: textures
    /// Intermidiate representation of the final canvas texture.
    var renderableTexture: Texture! // TODO: find a way of making this var not an optional
    /// Contains the grayscale points of the stroke.
    var grayscaleTexture: Texture!
    var strokeTexture: Texture!
    /// It contains the merge between the stroke texture and the current layer texture.
    var drawingTexture: Texture!
    
    // MARK: updatable by user
    var brushColor: Vector4
    var brushSize: Float
}
