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
    var currentCurve = Curve()
    
    var curveSectionToDraw = Curve()
    
    // textures state
    var canvasTexture: DrawableTexture?
    var drawingTexture: MTLTexture?
    var grayScaleTexture: MTLTexture?
    var strokeTexture: MTLTexture?
    var backgroundTexture: MTLTexture?
    var layerTexture: MTLTexture?
    var commandBuffer: MTLCommandBuffer?
   
    // current transformation matrix
    var ctm: CGAffineTransform = .identity
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    
    let canvasBackgroundColor: Color = (0.125, 0.125, 0.125, 1)
    
    init(canvasView: CanvasView) {
        self.canvasView = canvasView
        
        commandBuffer = Metal.commandQueue.makeCommandBuffer()
    }
}
