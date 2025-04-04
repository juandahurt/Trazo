//
//  CanvasController.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore
import TrazoEngine
import UIKit

@MainActor
class CanvasController: NSObject {
    weak var canvasView: CanvasView?
    
    var state: CanvasState
    let fingerTouchController = FingerTouchController()
   
    var currentLayer: Layer {
        state.layers[state.currentLayerIndex]
    }
    
    init(state: CanvasState) {
        self.state = state
        super.init()
        
        fingerTouchController.delegate = self
    }
    
    func load() {
        guard let canvasView else { return }
        let canvasSize: Vector2 = .init(
            x: Float(canvasView.bounds.width),
            y: Float(canvasView.bounds.height)
        )
        state.layers = [
            .init(size: canvasSize),
            .init(size: canvasSize, debubLabel: "Background Texture")
        ]
        // user starts drawing on the layer which is on top of the background layer
        state.currentLayerIndex = 0
        
        state.renderableTexture = TrazoEngine.makeTexture(
            ofSize: canvasSize,
            debugLabel: "Renderable Texture"
        )
        state.grayscaleTexture = TrazoEngine.makeTexture(
            ofSize: canvasSize,
            debugLabel: "Grayscale Texture"
        )
        state.strokeTexture = TrazoEngine.makeTexture(
            ofSize: canvasSize,
            debugLabel: "Stroke Texture"
        )
        state.drawingTexture = TrazoEngine.makeTexture(
            ofSize: canvasSize,
            debugLabel: "Drawing Texture"
        )
        
        // fill background layer with white color
        TrazoEngine.fillTexture(
            state.layers.last!.texture,
            withColor: [1, 1, 1, 1]
        )
        
        mergeLayers(usingDrawingTexture: false)
        
        // display canvas
        canvasView.setNeedsDisplay()
    }
}
