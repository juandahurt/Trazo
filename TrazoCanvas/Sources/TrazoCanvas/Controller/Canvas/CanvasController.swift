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
    
    private var state: CanvasState
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
            .init(texture: TrazoEngine.makeTexture(ofSize: canvasSize))
        ]
        
        // fill background layer with white color
        TrazoEngine.fillTexture(
            state.layers.last!.texture,
            withColor: [1, 1, 1, 1]
        )
        
        canvasView.setNeedsDisplay()
    }
}
