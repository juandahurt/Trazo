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
    
    private let fingerTouchesOrchestator = FingerTouchesOrchestator()
    
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        let touches = touches.map {
            let point = $0.location(in: _canvasState.canvasView)
            return Touch(
                id: $0.hashValue,
                location: .init(Float(point.x), Float(point.y)),
                phase: $0.phase
            )
        }
        fingerTouchesOrchestator.receivedTouches(touches)
    }
    
    func load(using canvasView: CanvasView) {
        _canvasState = CanvasState(canvasView: canvasView)
        _setupWorkflow.run(withState: &_canvasState)
        
        fingerTouchesOrchestator.onTransformChange = { [weak self] t in
            guard let self else { return }
            _canvasState.ctm = t
            _transformWorkflow.run(withState: &_canvasState)
        }
        
        fingerTouchesOrchestator.onDrawIntent = { [weak self] touch in
            guard let self else { return }
            _canvasState.inputTouch = touch
            _drawingWorkflow.run(withState: &_canvasState)
        }
        
        fingerTouchesOrchestator.onDrawFinished = { [weak self] in
            guard let self else { return }
            _endOfCurveWorkflow.run(withState: &_canvasState)
        }
    }
}
