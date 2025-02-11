//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import UIKit

let canvasWidth: Int = 800
let canvasHeight: Int = 800

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
        addRotationGesture()
        addSubviews()
        
        _viewModel.load(using: _canvasView)
    }
    
    func addSubviews() {
        addCanvasView()
    }
    
    func addPinchGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(
            target: self,
            action: #selector(onPinchGesture(_:))
        )
        pinchRecognizer.delegate = self
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func addRotationGesture() {
        let rotationRecognizer = UIRotationGestureRecognizer(
            target: self,
            action: #selector(onRotationGesture(_:))
        )
        rotationRecognizer.delegate = self
        view.addGestureRecognizer(rotationRecognizer)
    }
    
    func addCanvasView() {
        view.addSubview(_canvasView)
        
//        NSLayoutConstraint.activate([
//            _canvasView.heightAnchor.constraint(equalToConstant: CGFloat(canvasHeight)),
//            _canvasView.widthAnchor.constraint(equalToConstant: CGFloat(canvasWidth)),
//            _canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            _canvasView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
    }
}

extension ViewController {
    @objc
    func onPinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            _viewModel.scaleUpdated(newValue: recognizer.scale)
            recognizer.scale = 1
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

extension ViewController {
    @objc
    func onRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            self._canvasView.transform = self._canvasView.transform
                .rotated(by: recognizer.rotation)
            recognizer.rotation = 0
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
