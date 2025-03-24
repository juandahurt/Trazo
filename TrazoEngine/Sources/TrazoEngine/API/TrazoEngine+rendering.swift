//
//  TrazoEngine+rendering.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import MetalKit
import TrazoCore


extension TrazoEngine {
    public static func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    /// Merges two textures into a destination texture.
    /// - Parameters:
    ///   - textureA: Texture A.
    ///   - textureB: Texture B.
    ///   - destTexture: Destination texture.
    public static func merge(
        texture textureA: Texture,
        with textureB: Texture,
        on destTexture: Texture
    ) {
        guard let commandBuffer else { return }
        Renderer.merge(
            textureA.metalTexture,
            with: textureB.metalTexture,
            on: destTexture.metalTexture,
            using: commandBuffer
        )
    }
    
    /// Fills a texture with a desired color.
    /// - Parameters:
    ///   - texture: Texture to be filled.
    ///   - color: Color to be used.
    public static func fillTexture(_ texture: Texture, withColor color: Vector4) {
        guard let commandBuffer else { return }
        Renderer.fillTexture(
            texture: texture.metalTexture,
            with: color,
            using: commandBuffer
        )
    }
    
    /// Submits the commands to the GPU
    public static func commit() {
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }
}
