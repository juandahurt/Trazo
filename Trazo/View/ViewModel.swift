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
    
    private var disposeBag = Set<AnyCancellable>()
    
    func load(using canvasView: CanvasView) {
        _canvasState = CanvasState(canvasView: canvasView)
        _setupWorkflow.run(withState: &_canvasState)
        
        fingerTouchesOrchestator.ctmSubject.sink { transform in
            self._canvasState.ctm = transform
            self._transformWorkflow.run(withState: &self._canvasState)
        }.store(in: &disposeBag)
    }
}

class CanvasTransformer {
    /// First touch of finger A
    var initialTouchA: Touch?
    /// First touch of finger B
    var initialTouchB: Touch?
    
    var isInitialized: Bool {
        initialTouchA != nil && initialTouchB != nil
    }
    
    /// Current transformation matrix
    var ctm: CGAffineTransform = .identity
    private var ltm: CGAffineTransform = .identity
    
    func initialize(withTouches touchesDict: [Touch.ID: [Touch]]) {
        guard
            let keyA = touchesDict.keys.sorted().first,
            let keyB = touchesDict.keys.sorted().last,
            let touchA = touchesDict[keyA]?.first, // since we have only one touch in the array
            let touchB = touchesDict[keyB]?.first  // we select the first and only element
        else {
            fatalError("failed to initialize transformer")
        }
        initialTouchA = touchA
        initialTouchB = touchB
    }
    
    func tranform(
        usingCurrentTouches touchesDict: [Touch.ID: [Touch]],
        canvasCenter center: vector_t
    ) -> CGAffineTransform? {
        // logic found at: https://mortoray.com/a-pan-zoom-and-rotate-gesture-model-for-touch-devices/
        guard
            let initialTouchA,
            let initialTouchB,
            let lastTouchA = touchesDict[initialTouchA.id]?.last,
            let lastTouchB = touchesDict[initialTouchB.id]?.last
        else {
            return nil
        }
        
        let initialPointA = initialTouchA.location
        let currentPointA = lastTouchA.location
        let initialPointB = initialTouchB.location
        let currentPointB = lastTouchB.location
        
        // translation
        let startCenter = (initialPointA - initialPointB) / 2 + initialPointB
        let currentCenter = (currentPointA - currentPointB) / 2 + currentPointB
        
        let translationVector = currentCenter - startCenter
        let rawTranslation = CGPoint(
            x: CGFloat(translationVector.x),
            y: CGFloat(translationVector.y)
        )
        
        // rotation
        let startVector = initialPointA - initialPointB
        let currentVector = currentPointA - currentPointB
        
        let startAngle = atan2(startVector.y, startVector.x)
        let endAngle = atan2(currentVector.y, currentVector.x)
        
        let deltaAngle = endAngle - startAngle
        
        let rotationMatrix = CGAffineTransform(rotationAngle: -CGFloat(deltaAngle))
       
        // zooming
        let scale = currentVector.length() / startVector.length()
        
        let scaleMatrix = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        
        let translation = rawTranslation.applying(rotationMatrix) / CGFloat(scale)
        
        let translationMatrix = CGAffineTransform(
            translationX: translation.x,
            y: -translation.y
        )
        let matrix = translationMatrix.concatenating(rotationMatrix).concatenating(
            scaleMatrix
        )
        
        ltm = ctm.concatenating(matrix)
        return ctm.concatenating(matrix)
    }
    
    func reset() {
        initialTouchA = nil
        initialTouchB = nil
//        ltm = ctm
        ctm = ltm
    }
}

struct Touch {
    typealias ID = Int
    
    var id: ID
    var location: vector_t
    var phase: UITouch.Phase
}

class FingerTouchStore {
    private(set) var touchesDict: [Touch.ID: [Touch]] = [:]
    
    var numberOfTouches: Int {
        touchesDict.count
    }
    
    func save(_ touches: [Touch]) {
        for touch in touches {
            let key = touch.id
            if touchesDict[key] == nil {
                // if this is a new touch, we create an empty entry
                touchesDict[key] = []
            }
            // we append the touch to its corresponding key
            touchesDict[key]?.append(touch)
        }
    }
    
    func removeTouch(byID id: Touch.ID) {
        touchesDict.removeValue(forKey: id)
    }
}

import Combine

/// It holds and manages the touches that the user makes.
class FingerTouchesOrchestator {
    /// It holds the touches of the current gesture.
    let touchStore = FingerTouchStore()
    /// Transforms the canvas, given the current touches.
    let transformer = CanvasTransformer()
    
    let ctmSubject = PassthroughSubject<CGAffineTransform, Never>()
    
    private var isUserTransforming: Bool {
        touchStore.numberOfTouches == 2
    }
    
    private var hasUserLiftedFingers: Bool {
        touchStore.touchesDict.keys
//            .flatMap({ touchStore.touchesDict[$0] })
            .reduce(
                true,
                { $0 && (touchStore.touchesDict[$1]?.last?.phase == .ended || touchStore.touchesDict[$1]?.last?.phase == .cancelled)
                })
    }
   
//    private var hasUserLiftOffFingers: Bool {
//        for touches in touchStore.touchesDict.values {
//            let res = touches.reduce(false, { return $0 && $1.phase == .ended })
//        }
//    }
    
    func receivedTouches(_ touches: [Touch]) {
        print(touchStore.numberOfTouches)
        // first, we store the touches
        touchStore.save(touches)
        
        // then, we check which kind of action the user is trying to do
        if isUserTransforming {
            if !transformer.isInitialized {
                transformer.initialize(withTouches: touchStore.touchesDict)
            }
            if !hasUserLiftedFingers {
                if let matrix = transformer.tranform(
                    usingCurrentTouches: touchStore.touchesDict,
                    canvasCenter: .init(1640 / 2, 2360 / 2)
                ) {
                    ctmSubject.send(matrix)
                }
            } else {
                transformer.reset()
            }
        } else {
            // TODO: draw
            transformer.reset()
        }
        
        // check if the touches need to be removed (aka. the touch has finished)
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled {
                touchStore.removeTouch(byID: touch.id)
            }
        }
    }
}
