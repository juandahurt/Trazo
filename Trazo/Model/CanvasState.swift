//
//  CanvasState.swift
//  Trazo
//
//  Created by Juan Hurtado on 9/02/25.
//

import Metal
import UIKit

struct CanvasState {
    var canvasView: CanvasView
    
    // touches
    var inputTouch: UITouch = UITouch()
    var drawableTouch = DrawableTouch(
        positionInTextCoord: .zero,
        phase: .cancelled
    )
    
    // textures state
    var canvasTexture: DrawableTexture?
    var drawingTexture: MTLTexture?
    var grayScaleTexture: MTLTexture?
    var commandBuffer: MTLCommandBuffer?
    
    var scale: CGFloat = 1
    var transformScale: CGFloat = 1
    
    // used when we need to clear the background
    // for example, when user zooms or rotated the canvas
    var canvasBackgroundColor: Color?
    
    init(canvasView: CanvasView) {
        self.canvasView = canvasView
        
        commandBuffer = Metal.commandQueue.makeCommandBuffer()
    }
}
