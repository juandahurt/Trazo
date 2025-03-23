//
//  TrazoEngine+textures.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import TrazoCore

public extension TrazoEngine {
    static func makeTexture(ofSize size: Vector2, debugLabel: String? = nil) -> Texture {
        let metalTexture = TextureManager().createMetalTexture(
            ofSize: size,
            label: debugLabel
        )
        return .init(metalTexture: metalTexture)
    }
}
