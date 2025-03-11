//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import UIKit
import TrazoCore

class ViewModel {
    private var _canvasState: CanvasState!
    private var _drawingWorkflow = DrawingWorkflow()
    private let _setupWorkflow = SetupCanvasWorkflow()
    private let _transformWorkflow = TransformCanvasWorkflow()
    private let _endOfCurveWorkflow = EndOfCurveWorkflow()
   
    func brushSizeChanged(newValue value: Float) {
        _canvasState.brushSize = value
    }
    
    func colorSelected(newColor color: UIColor) {
        guard let components = color.cgColor.components else { return }
        _canvasState.selectedColor = (
            Float(components[0]),
            Float(components[1]),
            Float(components[2]),
            0.5 // TODO: use selected opacity value
        )
    }
    
    func scaleUpdated(newValue scale: CGFloat) {
        if _canvasState.scale > 4 && scale > 1 { return }
        if _canvasState.scale < 0.3 && scale < 1 { return }
        _canvasState.scale *= scale
        _transformWorkflow.run(withState: &_canvasState)
    }
   
    func rotationUpdated(newValue angle: CGFloat) {
        _canvasState.rotation += angle
        _transformWorkflow.run(withState: &_canvasState)
    }
   
    func translationUpdated(newValue translation: CGPoint) {
        _canvasState.translation += translation
        _transformWorkflow.run(withState: &_canvasState)
    }
    
    func onFingerTouch(_ touch: UITouch) {
        _canvasState.inputTouch = touch
        _drawingWorkflow.run(withState: &_canvasState)
        
        if touch.phase == .ended {
            _endOfCurveWorkflow.run(withState: &_canvasState)
            return
        }
    }
    
    func load(using canvasView: CanvasView) {
        _canvasState = CanvasState(canvasView: canvasView)
        _setupWorkflow.run(withState: &_canvasState)
    }
}
