//
//  TrazoEngine+textures.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import TrazoCore

public extension TrazoEngine {
    static func makeTexture(ofSize size: Vector2) -> Texture {
        let metalTexture = TextureManager().createMetalTexture(ofSize: size)
        return .init(metalTexture: metalTexture)
    }
}
