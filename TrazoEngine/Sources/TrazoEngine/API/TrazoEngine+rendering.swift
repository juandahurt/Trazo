//
//  TrazoEngine+rendering.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

import MetalKit
import TrazoCore


public extension TrazoEngine {
    static func colorize(
        grayscaleTexture: Texture,
        withColor color: Vector4,
        on outputTexture: Texture
    ) {
        guard let commandBuffer else { return }
        Renderer.colorize(
            grayscaleTexture: grayscaleTexture.metalTexture,
            withColor: color,
            on: outputTexture.metalTexture,
            using: commandBuffer
        )
    }
    
    /// Presents the metal drawable.
    /// - Parameter drawable: Metal drawable to be presented.
    static func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    /// Draws a set of grayscale points on a certain texture.
    /// - Parameters:
    ///   - points: Positions.
    ///   - size: Point size.
    ///   - transform: Matrix that will be applied to every point.
    ///   - grayscaleTexture: The texture where the points will be drawn into.
    static func drawGrayscalePoints(
        _ points: [DrawablePoint],
        transform: Mat4x4,
        projection: Mat4x4,
        on grayscaleTexture: Texture,
        clearingBackground: Bool
    ) {
        // TODO: create a struct for the gray points containg the location, size, etc.
        guard let commandBuffer else { return }
        let numPoints = points.count
        guard let buffer = GPU.device.makeBuffer(
            bytes: points,
            length: MemoryLayout<DrawablePoint>.stride * numPoints
        ) else { return }
        Renderer.drawGrayscalePoints(
            positionsBuffer: buffer,
            numPoints: numPoints,
            on: grayscaleTexture.metalTexture,
            transform: transform,
            projection: projection,
            using: commandBuffer,
            clearingBackground: clearingBackground
        )
    }
    
    static func drawTexture(
        _ texture: Texture,
        on outputTexture: MTLTexture,
        clearColor: Vector4,
        transform: Mat4x4,
        projection: Mat4x4
    ) {
        guard let commandBuffer else { return }
        Renderer.drawTexture(
            texture.metalTexture,
            on: outputTexture,
            using: commandBuffer,
            clearColor: clearColor,
            transform: transform,
            projection: projection
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
