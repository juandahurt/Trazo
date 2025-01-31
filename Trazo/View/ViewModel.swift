//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import UIKit

struct DrawableTouch {
    var position: CGPoint
    var positionInTextCoord: CGPoint
    var phase: UITouch.Phase
}

class ViewModel {
    var canvasView: CanvasView?
    private var _state: CanvasState
    private let _painter = Painter()
    
    init() {
        _state = CanvasState()
        _painter.delegate = self
    }
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        guard let canvasView else { return }
        let drawableTouches = touches.map {
            let position = $0.location(in: canvasView)
//            let x = position.x / canvasView.bounds.width
//            let y = 1 - (position.y / canvasView.bounds.height)
            let x = (position.x / canvasView.bounds.width) * 2 - 1
            let y = 1 - (position.y / canvasView.bounds.height) * 2
            return DrawableTouch(
                position: position,
                positionInTextCoord: .init(x: x, y: y),
                phase: $0.phase
            )
        }
        _painter.handle(fingerTouches: drawableTouches)
    }
    
    func loadCanvas(using canvasView: CanvasView) {
        _state.load(canvasSize: canvasView.bounds)
        _painter.load(canvasSize: canvasView.bounds)
        _painter.fillTexture(_state.canvasTexture, with: (r: 1, g: 1, b: 1, a: 1))
        self.canvasView = canvasView
    }
    
    func presentCanvas(_ drawable: CAMetalDrawable) {
        _painter.drawTexture(_state.canvasTexture, on: drawable.texture)
        _painter.present(drawable)
        _painter.resetCommandBuffer()
    }
}

extension ViewModel: PainterDelegate {
    func canvasViewNeedsUpdate() {
        canvasView?.setNeedsDisplay()
    }
}
