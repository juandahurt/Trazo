//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit

class CanvasView: MTKView, MTKViewDelegate {
    private var _canvasTexture: MTLTexture?
    private var _renderer: Renderer?
    
    init(frame: CGRect) {
        super.init(frame: frame, device: Metal.device)
      
        colorPixelFormat = .rgba8Unorm
        
        // TODO: move texture creation to another place
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        textureDescriptor.width = Int(bounds.width)
        textureDescriptor.height = Int(bounds.height)
        _canvasTexture = Metal.device.makeTexture(descriptor: textureDescriptor)
        
        _renderer = Renderer()
        
        delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        guard let renderer = _renderer else { return }
        guard let currentDrawable else { return }
        guard let commandBuffer = Metal.commandQueue.makeCommandBuffer() else { return }
        
        renderer.fillTexture(
            texture: _canvasTexture!,
            with: (r: 255, g: 255, b: 255),
            using: commandBuffer
        )
        
        renderer.drawTexture(
            texture: _canvasTexture!,
            on: currentDrawable.texture,
            using: commandBuffer
        )
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
