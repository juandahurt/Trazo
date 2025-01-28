//
//  Painter.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import Metal

class Painter {
    private var _commandBuffer: MTLCommandBuffer?
    
    func present(_ drawable: MTLDrawable) {
        _commandBuffer?.present(drawable)
        _commandBuffer?.commit()
    }
    
    func reset() {
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
