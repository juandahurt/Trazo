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
    
    func toggleVisibilty(ofLayerAtIndex index: Int) {
        state.layers[index].isVisible = !state.layers[index].isVisible
        clearRenderableTexture()
        mergeLayers(usingDrawingTexture: false)
        canvasView?.setNeedsDisplay()
        
        delegate?.didUpdateLayer(state.layers[index], atIndex: index)
    }
}
