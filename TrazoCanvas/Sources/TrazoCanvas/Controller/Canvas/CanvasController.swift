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
        state.currentLayerIndex = 1
        
        state.renderableTexture = TrazoEngine
            .makeTexture(ofSize: canvasSize, debugLabel: "Renderable Texture")
        
        // fill background layer with white color
        TrazoEngine.fillTexture(
            state.layers.last!.texture,
            withColor: [1, 1, 1, 1]
        )
        
        // merge layers to the renderable texture
        for layer in state.layers {
            TrazoEngine.merge(
                texture: layer.texture,
                with: state.renderableTexture!,
                on: state.renderableTexture!
            )
        }
        
        // display canvas
        canvasView.setNeedsDisplay()
    }
}
