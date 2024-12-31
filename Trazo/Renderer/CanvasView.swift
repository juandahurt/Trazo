//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

struct RendererSettings {
    static let pixelFormat = MTLPixelFormat.rgba8Unorm
}

class CanvasView: MTKView {
    let renderer = Renderer()
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU unavailable")
        }
        super.init(frame: .zero, device: device)
        
        colorPixelFormat = RendererSettings.pixelFormat
        clearColor = .init(red: 0.1, green: 0.3, blue: 0.3, alpha: 1)
        
        delegate = renderer
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CanvasView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        
    }
}
