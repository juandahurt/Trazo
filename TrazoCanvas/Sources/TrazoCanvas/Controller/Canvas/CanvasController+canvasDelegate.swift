//
//  CanvasController+canvasDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 23/03/25.
//

import MetalKit
import TrazoEngine

extension CanvasController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: check if I need to do something here
    }

    func draw(in view: MTKView) {
        // guard let currentDrawable else { return }
        
        // TrazoEngine.drawTexture(..., on: currentDrawable.texture)
        
        // TrazoEngine.present(currentDrawable)
        
        TrazoEngine.commit()
        TrazoEngine.reset()
    }
}
