//
//  CanvasView.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 19/03/25.
//

import MetalKit
import TrazoEngine

class CanvasView: MTKView {
    init(
        fingerGestureDelegate: FingerGestureRecognizerDelegate,
        pencilGestureDelegate: PencilGestureRecognizerDelegate
    ) {
        // TODO: remove device creation from here
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("") }
        super.init(frame: .zero, device: device)
      
        colorPixelFormat = .rgba8Unorm
        
        enableSetNeedsDisplay = true
        isPaused = true
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let fingerGesture = FingerGestureRecognizer()
        fingerGesture.fingerGestureDelegate = fingerGestureDelegate
        addGestureRecognizer(fingerGesture)
        
        let pencilGesture = PencilGestureRecognizer()
        pencilGesture.pencilGestureDelegate = pencilGestureDelegate
        addGestureRecognizer(pencilGesture)
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
}
