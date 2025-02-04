//
//  Painter.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import MetalKit
import UIKit

class Painter {
    private var _canvasTexture: DrawableTexture?
    private var _drawingTexture: MTLTexture?
    private var _grayScaleTexture: MTLTexture?
    private var _commandBuffer: MTLCommandBuffer?
   
    private let _canvasView: MTKView
    
    init(canvasView: MTKView) {
        _canvasView = canvasView
        load()
    }
    
    func draw(fingerTouches touches: [DrawableTouch]) {
        guard let _grayScaleTexture, let _drawingTexture, let _commandBuffer else {
            return
        }
        // TODO: stop creating buffer per function cal
        let touchesPos: [simd_float2] = touches.map {
            [Float($0.positionInTextCoord.x), Float($0.positionInTextCoord.y)]
        }
        let positionsBuffer = Metal.device
            .makeBuffer(
                bytes: touchesPos,
                length: MemoryLayout<simd_float2>.stride * touches.count
            )
        // draw grayscale points
        Renderer.instance.drawGrayPoints(
            positionsBuffer: positionsBuffer!,
            numPoints: touches.count,
            on: _grayScaleTexture,
            using: _commandBuffer
        )
        
        // colorize points
        Renderer.instance.colorize(
            grayscaleTexture: _grayScaleTexture,
            withColor: (0, 0, 1, 1), //TODO: remove mock color
            on: _drawingTexture,
            using: _commandBuffer
        )
        
        // merge `drawingTexture` with `canvasTexture`
        Renderer.instance.merge(
            _drawingTexture,
            to: _canvasTexture!.actualTexture,
            using: _commandBuffer
        )
        
        let phase = touches.first?.phase
        if phase == .cancelled || phase == .ended {
            print("stroke ended")
        }
    }
    
    func clearTextures() {
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: _grayScaleTexture!),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: _commandBuffer!
        )
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: _drawingTexture!),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: _commandBuffer!
        )
    }
   
    func present() {
        guard let drawable = _canvasView.currentDrawable else { return }
        drawTexture(_canvasTexture!, on: drawable.texture)
        _commandBuffer?.present(drawable)
        _commandBuffer?.commit()
        _commandBuffer?.waitUntilCompleted()
        
        _canvasView.setNeedsDisplay()
    }
    
    func load() {
        let canvasSize = _canvasView.bounds
        resetCommandBuffer()
        _canvasTexture = TextureManager().createDrawableTexture(ofSize: canvasSize)
        _grayScaleTexture = TextureManager().createMetalTexture(ofSize: canvasSize)
        _drawingTexture = TextureManager().createMetalTexture(ofSize: canvasSize)
        guard let _grayScaleTexture, let _commandBuffer, let _drawingTexture else {
            return
        }
        Renderer.instance.fillTexture(
            texture: _canvasTexture!,
            with: (r: 1, g: 1, b: 1, a: 1),
            using: _commandBuffer
        )
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: _grayScaleTexture),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: _commandBuffer
        )
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: _drawingTexture),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: _commandBuffer
        )
    }
    
    func resetCommandBuffer() {
        _commandBuffer = Metal.commandQueue.makeCommandBuffer()
    }
    
    func fillTexture(
        _ texture: DrawableTexture,
        with color: Color
    ) {
        guard let _commandBuffer else { return }
        Renderer.instance.fillTexture(
            texture: texture,
            with: color,
            using: _commandBuffer
        )
    }
    
    func drawTexture(_ texture: DrawableTexture, on ouputTexture: MTLTexture) {
        guard let _commandBuffer else { return }
        Renderer.instance.drawTexture(
            texture: texture,
            on: ouputTexture,
            using: _commandBuffer
        )
    }
}
