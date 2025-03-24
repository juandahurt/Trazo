//
//  TrazoEngine+rendering.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import MetalKit
import TrazoCore


public extension TrazoEngine {
    static func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    static func drawTexture(
        _ texture: Texture,
        on outputTexture: MTLTexture,
        clearColor: Vector4,
        transform: Mat4x4
    ) {
        guard let commandBuffer else { return }
        Renderer.drawTexture(
            texture.metalTexture,
            on: outputTexture,
            using: commandBuffer,
            clearColor: clearColor,
            transform: transform
        )
    }
    
    /// Merges two textures into a destination texture.
    /// - Parameters:
    ///   - textureA: Texture A.
    ///   - textureB: Texture B.
    ///   - destTexture: Destination texture.
    static func merge(
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
    static func fillTexture(_ texture: Texture, withColor color: Vector4) {
        guard let commandBuffer else { return }
        Renderer.fillTexture(
            texture: texture.metalTexture,
            with: color,
            using: commandBuffer
        )
    }
    
    /// Submits the commands to the GPU
    static func commit() {
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }
}
