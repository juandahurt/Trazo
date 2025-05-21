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
protocol CanvasControllerDelegate: AnyObject {
    func didLoadLayers(_ layers: [Layer], currentLayerIndex: Int)
    func didUpdateLayer(_ layer: Layer, atIndex index: Int, currentLayerIndex: Int)
    func didUpdateTexture(_ texture: Texture, ofLayerAtIndex index: Int)
}

@MainActor
class CanvasController: NSObject {
    weak var canvasView: CanvasView?
    weak var delegate: CanvasControllerDelegate?
    
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
            x: Float(canvasView.bounds.width * canvasView.contentScaleFactor),
            y: Float(canvasView.bounds.height * canvasView.contentScaleFactor)
        )
        state.layers = [
            .init(named: "Layer 1", size: canvasSize),
            .init(named: "Background", size: canvasSize, debubLabel: "Background Texture")
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
        
        delegate?.didLoadLayers(state.layers, currentLayerIndex: state.currentLayerIndex)
    }
}
