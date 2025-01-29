//
//  TextureManager.swift
//  Trazo
//
//  Created by Juan Hurtado on 27/01/25.
//

import Metal

class TextureManager {
    func createTexture(ofSize size: CGRect) -> DrawableTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = Int(size.width)
        descriptor.height = Int(size.height)
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.usage = [.shaderRead, .shaderWrite]
        // I don't think we'll find any issues if se create them all using
        // the same descriptor :)
        guard let metalTexture = Metal.device.makeTexture(descriptor: descriptor) else {
            fatalError("The texture couldn't be created.")
        }
        
        return DrawableTexture(metalTexture: metalTexture)
    }
}
