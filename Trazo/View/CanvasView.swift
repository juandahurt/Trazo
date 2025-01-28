//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit

protocol CanvasViewDelegate: AnyObject {
    func drawCanvas(onDrawable drawable: CAMetalDrawable)
}

class CanvasView: MTKView, MTKViewDelegate {
    weak var canvasDelegate: CanvasViewDelegate?
    
    init(frame: CGRect) {
        super.init(frame: frame, device: Metal.device)
      
        colorPixelFormat = .rgba8Unorm
        
        delegate = self
        enableSetNeedsDisplay = true
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        guard let currentDrawable else { return }
        canvasDelegate?.drawCanvas(onDrawable: currentDrawable)
    }
}
