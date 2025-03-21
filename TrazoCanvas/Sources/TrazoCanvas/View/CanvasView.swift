//
//  CanvasView.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 19/03/25.
//

import MetalKit

class CanvasView: MTKView, MTKViewDelegate {    
    init(fingerGestureDelegate: FingerGestureRecognizerDelegate) {
        // TODO: remove device creation from here
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("") }
        super.init(frame: .zero, device: device)
      
        colorPixelFormat = .rgba8Unorm
        
        delegate = self
        enableSetNeedsDisplay = true
        isPaused = true
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let fingerGesture = FingerGestureRecognizer()
        fingerGesture.fingerGestureDelegate = fingerGestureDelegate
        addGestureRecognizer(fingerGesture)
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        // TODO: present canvas
    }
}
