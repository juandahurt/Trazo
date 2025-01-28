//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit

class CanvasView: MTKView, MTKViewDelegate {
    private var _canvasTexture: Texture!
    private let _renderer = Renderer()
    
    private var _commandBuffer: MTLCommandBuffer?
    
    init(frame: CGRect) {
        super.init(frame: frame, device: Metal.device)
      
        colorPixelFormat = .rgba8Unorm

        _makeCommandBuffer()
        _setupCanvasTexture()
        
        delegate = self
        enableSetNeedsDisplay = true
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    private func _setupCanvasTexture() {
        guard let _commandBuffer else {
            return
        }
        _canvasTexture = TextureManager().createTexture(ofSize: bounds)
        _renderer.fillTexture(
            texture: _canvasTexture,
            with: (r: 255, g: 255, b: 255),
            using: _commandBuffer
        )
    }
    
    private func _makeCommandBuffer() {
        _commandBuffer = Metal.commandQueue.makeCommandBuffer()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        guard
            let currentDrawable,
            let _commandBuffer
        else { return }
        
        _renderer.drawTexture(
            texture: _canvasTexture,
            on: currentDrawable.texture,
            using: _commandBuffer
        )
        
        _commandBuffer.present(currentDrawable)
        _commandBuffer.commit()
        
        _makeCommandBuffer()
    }
}
