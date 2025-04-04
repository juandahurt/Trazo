//
//  TextureManager.swift
//  Trazo
//
//  Created by Juan Hurtado on 27/01/25.
//

import Metal
import TrazoCore

@MainActor
class TextureManager {
    func createMetalTexture(
        ofSize size: Vector2,
        label: String? = nil
    ) -> MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = Int(size.x)
        descriptor.height = Int(size.y)
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        // I don't think we'll find any issues if se create them all using
        // the same descriptor :)
        guard let metalTexture = GPU.device.makeTexture(descriptor: descriptor) else {
            fatalError("The texture couldn't be created.")
        }
        metalTexture.label = label
        return metalTexture
    }
}
