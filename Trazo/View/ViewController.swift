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
    private lazy var _colorPickerView: UIView = {
        let pickerView = UIButton()
        pickerView
            .addTarget(self, action: #selector(onColorPickerTap), for: .touchUpInside)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
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
        addPanGesture()
        addSubviews()
        
        _viewModel.load(using: _canvasView)
    }
    
    func addSubviews() {
        addCanvasView()
        addColorPickerView()
    }
    
    func addColorPickerView() {
        view.addSubview(_colorPickerView)
        
        NSLayoutConstraint.activate([
            view.trailingAnchor
                .constraint(equalTo: _colorPickerView.trailingAnchor, constant: 40),
            view.bottomAnchor
                .constraint(equalTo: _colorPickerView.bottomAnchor, constant: 40),
            _colorPickerView.heightAnchor.constraint(equalToConstant: 60),
            _colorPickerView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        _colorPickerView.layer.cornerRadius = 20
        _colorPickerView.backgroundColor = .red
    }
   
    // There's a memory leak when presenting this color picker, I tested it and it's not my fault.
    // Some internal CGRetain or something like that doesn't release the CGColor obj... so,
    // basically everty time you select a color you will leak 96 bytes of memory :)
    // I will solve this, hopefully, when creating my own color picker
    @objc
    func onColorPickerTap() {
        let pickerViewController = UIColorPickerViewController()
        pickerViewController.modalPresentationStyle = .popover
        pickerViewController.popoverPresentationController?.sourceView = _colorPickerView
        pickerViewController.supportsAlpha = false
        pickerViewController.delegate = self
        present(pickerViewController, animated: true)
    }
    
    func addPanGesture() {
        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(onPanGesture(_:))
        )
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
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
        
        NSLayoutConstraint.activate([
            _canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            _canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Gestures
extension ViewController {
    @objc
    func onPinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            _viewModel.scaleUpdated(newValue: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @objc
    func onRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            _viewModel.rotationUpdated(newValue: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @objc
    func onPanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        _viewModel.translationUpdated(newValue: translation)
        recognizer.setTranslation(.zero, in: view)
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

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        _colorPickerView.backgroundColor = color
        _viewModel.colorSelected(newColor: color)
    }
}
