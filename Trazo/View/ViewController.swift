//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import UIKit

class ViewController: UIViewController {
    private lazy var _brushSizeSliderView: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 3
        slider.maximumValue = 30
        slider.value = 6
        slider.addTarget(self, action: #selector(onBrushSizeSliderChange(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var _colorPickerView: UIView = {
        let pickerView = UIButton()
        pickerView
            .addTarget(self, action: #selector(onColorPickerTap), for: .touchUpInside)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    private lazy var _fingerGestureRecognizer: FingerGestureRecognizer = {
        let fingerGestureRecognizer = FingerGestureRecognizer()
        fingerGestureRecognizer.fingerGestureDelegate = self
        return fingerGestureRecognizer
    }()
    
    private lazy var _canvasView: CanvasView = {
        let canvasView = CanvasView(frame: view.frame)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        let pencilGesture = PencilGestureRecognizer()
        pencilGesture.pencilGestureDelegate = self
        
        canvasView.addGestureRecognizer(pencilGesture)
        canvasView.addGestureRecognizer(_fingerGestureRecognizer)
        return canvasView
    }()
    
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
        
        addSubviews()
        
        viewModel.load(using: _canvasView)
    }
    
    func addSubviews() {
        addCanvasView()
        addColorPickerView()
        addOpacitySlider()
    }
    
    func addOpacitySlider() {
        view.addSubview(_brushSizeSliderView)
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(
                equalTo: _brushSizeSliderView.bottomAnchor,
                constant: 40
            ),
            view.centerXAnchor.constraint(
                equalTo: _brushSizeSliderView.centerXAnchor
            ),
            _brushSizeSliderView.widthAnchor.constraint(
                equalToConstant: 200
            )
        ])
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
        _colorPickerView.backgroundColor = .black
    }
   
    @objc
    func onBrushSizeSliderChange(_ sender: UISlider) {
        viewModel.brushSizeChanged(newValue: sender.value)
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
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        viewModel.didReceiveFingerTouches(touches)
    }
}

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        _colorPickerView.backgroundColor = color
        viewModel.colorSelected(newColor: color)
    }
}
