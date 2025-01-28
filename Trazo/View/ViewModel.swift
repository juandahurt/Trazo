//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import UIKit

class ViewModel {
    private var _state: CanvasState
    private let _painter = Painter()
    
    init() {
        _state = CanvasState()
    }
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        
    }
    
    func loadCanvas(ofSize size: CGRect) {
        _state.load(canvasSize: size)
        _painter.reset()
        _painter.fillTexture(_state.canvasTexture, with: (r: 1, g: 1, b: 1))
    }
    
    func presentCanvas(_ drawable: CAMetalDrawable) {
        _painter.drawTexture(_state.canvasTexture, on: drawable.texture)
        _painter.present(drawable)
        _painter.reset()
    }
}

class CanvasState {
    private var _canvasTexture: DrawableTexture?
    var canvasTexture: DrawableTexture {
        assert(_canvasTexture != nil, "load function has not been called.")
        return _canvasTexture!
    }
    var initialized = false
    
    init() {}
    
    func load(canvasSize: CGRect) {
        _canvasTexture = TextureManager().createTexture(ofSize: canvasSize)
        initialized = true
    }
}

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
