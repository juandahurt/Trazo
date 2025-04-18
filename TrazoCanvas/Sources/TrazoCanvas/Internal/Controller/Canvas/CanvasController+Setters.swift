//
//  CanvasController+Setters.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 28/03/25.
//

import TrazoCore

extension CanvasController {
    func setBrushColor(_ color: Vector4) {
        state.brushColor = color
    }
    
    func setBrushSize(_ size: Float) {
        state.brushSize = size
    }
    
    func setIsVisible(_ isVisible: Bool, toLayerAtIndex index: Int) {
        state.layers[index].isVisible = isVisible
        mergeLayers(usingDrawingTexture: false)
        canvasView?.setNeedsDisplay()
    }
}
