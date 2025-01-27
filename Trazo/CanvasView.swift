//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit

class CanvasView: MTKView, MTKViewDelegate {
    private var _canvasTexture: MTLTexture?
    
    init() {
        super.init(frame: .zero, device: Metal.device)
       
        // TODO: move texture creation to another place
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.usage = [.shaderWrite]
        _canvasTexture = Metal.device.makeTexture(descriptor: textureDescriptor)
        
        delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        guard let currentDrawable else { return }
        let commandBuffer = Metal.commandQueue.makeCommandBuffer()
        commandBuffer?.commit()
        commandBuffer?.present(currentDrawable)
    }
}
