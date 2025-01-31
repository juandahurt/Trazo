//
//  CanvasState.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import CoreGraphics

class CanvasState {
    private var _canvasTexture: DrawableTexture?
    var canvasTexture: DrawableTexture {
        assert(_canvasTexture != nil, "load function has not been called.")
        return _canvasTexture!
    }
    var initialized = false
    
    init() {}
    
    func load(canvasSize: CGRect) {
        _canvasTexture = TextureManager().createDrawableTexture(ofSize: canvasSize)
        initialized = true
    }
}
