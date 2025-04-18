//
//  Layer.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 22/03/25.
//

import TrazoEngine
import TrazoCore

@MainActor
class Layer {
    var isVisible = true
    let texture: Texture
    
    init(size: Vector2, debubLabel: String? = nil) {
        texture = TrazoEngine.makeTexture(ofSize: size, debugLabel: debubLabel)
    }
}
