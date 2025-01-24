//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

struct Brush {
    var textureName: String
    var texture: MTLTexture?
    
    mutating func load(using device: MTLDevice) {
        let textureLoader = MTKTextureLoader(device: device)
        
        guard let url = Bundle.main.url(
            forResource: textureName,
            withExtension: "png"
        ) else {
            return
        }
        texture = try? textureLoader.newTexture(URL: url)
    }
}

struct RendererSettings {
    static let pixelFormat = MTLPixelFormat.rgba8Unorm
}

struct Line {
    var points: [Point]
}

class CanvasView: MTKView {
    let manager = CanvasManager()
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU unavailable")
        }
        super.init(frame: .zero, device: device)
        
        colorPixelFormat = RendererSettings.pixelFormat
        manager.setup(with: self)
        self.enableSetNeedsDisplay = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
