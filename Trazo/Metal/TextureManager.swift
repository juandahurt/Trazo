//
//  TextureManager.swift
//  Trazo
//
//  Created by Juan Hurtado on 27/01/25.
//

import Metal

class TextureManager {
    func createMetalTexture(ofSize size: CGRect) -> MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = Int(size.width)
        descriptor.height = Int(size.height)
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        // I don't think we'll find any issues if se create them all using
        // the same descriptor :)
        guard let metalTexture = Metal.device.makeTexture(descriptor: descriptor) else {
            fatalError("The texture couldn't be created.")
        }
        return metalTexture
    }
    
    func createDrawableTexture(ofSize size: CGRect) -> DrawableTexture {
        let metalTexture = createMetalTexture(ofSize: size)
        return DrawableTexture(metalTexture: metalTexture)
    }
}
