//
//  Layer.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 22/03/25.
//

import TrazoEngine
import TrazoCore

@MainActor
public class Layer {
    var title: String
    var isVisible = true
    public let texture: Texture
    
    init(named title: String, size: Vector2, debubLabel: String? = nil) {
        self.title = title
        texture = TrazoEngine.makeTexture(ofSize: size, debugLabel: debubLabel)
    }
}
