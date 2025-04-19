//
//  Texture.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import Metal

public class Texture {
    var metalTexture: MTLTexture
    
    init(metalTexture: MTLTexture) {
        self.metalTexture = metalTexture
    }
}
