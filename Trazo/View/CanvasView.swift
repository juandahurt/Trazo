//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import Combine
import MetalKit

class CanvasView: MTKView, MTKViewDelegate {
    init(frame: CGRect) {
        super.init(frame: frame, device: Metal.device)
      
        colorPixelFormat = .rgba8Unorm
        
        delegate = self
        enableSetNeedsDisplay = true
        isPaused = true
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        // TODO: check if I need to do something here
    }
}
