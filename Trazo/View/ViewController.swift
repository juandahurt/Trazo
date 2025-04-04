//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import Combine
import UIKit

class ViewController: UIViewController {
    private lazy var _brushSizeSliderView: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = viewModel.minBrushSize
        slider.maximumValue = viewModel.maxBrushSize
        slider.value = viewModel.initialBrushSize
        slider.addTarget(self, action: #selector(onBrushSizeSliderChange(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var colorPickerView: UIView = {
        let pickerView = UIButton()
        pickerView
            .addTarget(self, action: #selector(onColorPickerTap), for: .touchUpInside)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
        
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        viewModel.viewDidLayoutSubviews()
    }
    
    private func setupSubviews() {
        let canvasView = viewModel.canvasView
        view.addSubview(canvasView)
        canvasView.makeEgdes(equalTo: view)
        
        addColorPickerView()
        addBrushSizeSlider()
    }
    
    func addBrushSizeSlider() {
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
        view.addSubview(colorPickerView)
        
        NSLayoutConstraint.activate([
            view.trailingAnchor
                .constraint(equalTo: colorPickerView.trailingAnchor, constant: 40),
            view.bottomAnchor
                .constraint(equalTo: colorPickerView.bottomAnchor, constant: 40),
            colorPickerView.heightAnchor.constraint(equalToConstant: 60),
            colorPickerView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        colorPickerView.layer.cornerRadius = 20
        colorPickerView.backgroundColor = viewModel.initialBrushColor
    }
    
    @objc
    func onBrushSizeSliderChange(_ sender: UISlider) {
        viewModel.didBrushSizeChange(sender.value)
    }
    
    // There's a memory leak when presenting this color picker, I tested it and it's not my fault.
    // Some internal CGRetain or something like that doesn't release the CGColor obj... so,
    // basically everty time you select a color you will leak 96 bytes of memory :)
    // I will solve this, hopefully, when creating my own color picker
    @objc
    func onColorPickerTap() {
        let pickerViewController = UIColorPickerViewController()
        pickerViewController.modalPresentationStyle = .popover
        pickerViewController.popoverPresentationController?.sourceView = colorPickerView
        pickerViewController.delegate = self
        present(pickerViewController, animated: true)
    }
}

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        colorPickerView.backgroundColor = color.withAlphaComponent(1)
        viewModel.didSelectColor(color)
    }
}
