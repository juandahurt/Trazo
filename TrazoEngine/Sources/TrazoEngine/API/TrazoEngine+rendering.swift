//
//  TrazoEngine+rendering.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import Metal
import TrazoCore



extension TrazoEngine {
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
