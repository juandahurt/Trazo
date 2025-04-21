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
        
        delegate?
            .didUpdateLayer(
                state.layers[index],
                atIndex: index,
                currentLayerIndex: state.currentLayerIndex
            )
    }
    
    func setCurrentLayerIndex(_ index: Int) {
        let prevLayerIndex = state.currentLayerIndex
        state.currentLayerIndex = index
        // update the previous and the new selected layer
        delegate?.didUpdateLayer(
            state.layers[prevLayerIndex],
            atIndex: prevLayerIndex,
            currentLayerIndex: state.currentLayerIndex
        )
        delegate?.didUpdateLayer(
            state.layers[index],
            atIndex: index,
            currentLayerIndex: state.currentLayerIndex
        )
    }
}
