//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import UIKit

class ViewModel {
    private var _state: CanvasState
    private let _painter = Painter()
    
    init() {
        _state = CanvasState()
    }
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        
    }
    
    func loadCanvas(ofSize size: CGRect) {
        _state.load(canvasSize: size)
        _painter.reset()
        _painter.fillTexture(_state.canvasTexture, with: (r: 1, g: 1, b: 1))
    }
    
    func presentCanvas(_ drawable: CAMetalDrawable) {
        _painter.drawTexture(_state.canvasTexture, on: drawable.texture)
        _painter.present(drawable)
        _painter.reset()
    }
}
