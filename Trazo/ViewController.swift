//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import UIKit

let canvasWidth: Int = 500
let canvasHeight: Int = 500

class ViewController: UIViewController {
    private lazy var _canvasView: CanvasView = {
        let canvasView = CanvasView(frame: view.frame)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        let pencilGesture = PencilGestureRecognizer()
        pencilGesture.pencilGestureDelegate = self
        
        let fingerGestureRecognizer = FingerGestureRecognizer()
        fingerGestureRecognizer.fingerGestureDelegate = self
        
        canvasView.addGestureRecognizer(pencilGesture)
        canvasView.addGestureRecognizer(fingerGestureRecognizer)
        return canvasView
    }()
    
    private var _viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
        
        addPinchGesture()
        addSubviews()
        
        _viewModel.canvasView = _canvasView
    }
    
    func addSubviews() {
        addCanvasView()
    }
    
    func addPinchGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(
            target: self,
            action: #selector(onPinchGesture(_:))
        )
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func addCanvasView() {
        view.addSubview(_canvasView)
        
        NSLayoutConstraint.activate([
            _canvasView.heightAnchor.constraint(equalToConstant: CGFloat(canvasHeight)),
            _canvasView.widthAnchor.constraint(equalToConstant: CGFloat(canvasWidth)),
            _canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            _canvasView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension ViewController {
    @objc
    func onPinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            _canvasView.transform = _canvasView.transform
                .scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
}

extension ViewController: PencilGestureRecognizerDelegate {
    func onPencilEstimatedTouches(_ touches: Set<UITouch>) {
        // TODO: send estimated touches
    }
    
    func onPencilActualTocuhes(_ touches: Set<UITouch>) {
        // TODO: send actual touches
    }
}

extension ViewController: FingerGestureRecognizerDelegate {
    func onFingerTouches(_ touches: Set<UITouch>) {
        _viewModel.onFingerTouches(touches)
    }
}

class ViewModel {
    var canvasView: UIView?
    
    func onFingerTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            print(touch.location(in: canvasView))
        }
    }
}
