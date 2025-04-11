//
//  ToolbarView.swift
//  Trazo
//
//  Created by Juan Hurtado on 5/04/25.
//

import UIKit

protocol ToolbarViewDelegate: AnyObject {
    func toolbarViewDidRequestPresentingViewControllerForColorPicker(
        _ toolbarView: ToolbarView
    ) -> UIViewController
    func toolbarView(_ toolbarView: ToolbarView, didSelect color: UIColor)
}

class ToolbarView: UIView {
    private lazy var colorPreviewView: UIButton = {
        let preview = UIButton(frame: .zero)
        preview.addTarget(
            self,
            action: #selector(onColorPreviewTap),
            for: .touchUpInside
        )
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.layer.cornerRadius = 30 / 2
        preview.backgroundColor = .blue
        preview.layer.borderColor = .init(
            red: 0.61,
            green: 0.61,
            blue: 0.61,
            alpha: 1
        )
        preview.layer.borderWidth = 1.5
        return preview
    }()
    
    private let itemsCenterStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var layersItemView: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "square.2.layers.3d.fill")
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white.withAlphaComponent(0.85)
        
        return button
    }()
    
    weak var delegate: ToolbarViewDelegate?
    
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(
            red: 0.11,
            green: 0.11,
            blue: 0.11,
            alpha: 1
        )
        
        setupItems()
    }
    
    // There's a memory leak when presenting this color picker, I tested it and it's not my fault.
    // Some internal CGRetain or something like that doesn't release the CGColor obj... so,
    // basically everty time you select a color you will leak 96 bytes of memory :)
    // I will solve this, hopefully, when creating my own color picker
    @objc
    private func onColorPreviewTap() {
        guard
            let viewController = delegate?.toolbarViewDidRequestPresentingViewControllerForColorPicker(self)
        else {
            return
        }
        let pickerViewController = UIColorPickerViewController()
        pickerViewController.modalPresentationStyle = .popover
        pickerViewController.popoverPresentationController?.sourceView = colorPreviewView
        pickerViewController.delegate = self
        viewController.present(pickerViewController, animated: true)
    }
}

// MARK: Color picker delegate
extension ToolbarView: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        colorPreviewView.backgroundColor = color.withAlphaComponent(1)
        delegate?.toolbarView(self, didSelect: color)
    }
}

extension ToolbarView {
    func setupItems() {
        setupCenterItems()
    }
    
    func setupCenterItems() {
        addSubview(itemsCenterStackView)
        
        NSLayoutConstraint.activate([
            itemsCenterStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            itemsCenterStackView.bottomAnchor
                .constraint(equalTo: bottomAnchor, constant: -10),
            itemsCenterStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        itemsCenterStackView.addArrangedSubview(layersItemView)
        itemsCenterStackView.addArrangedSubview(colorPreviewView)
        
        NSLayoutConstraint.activate([
            colorPreviewView.widthAnchor.constraint(equalToConstant: 30),
            layersItemView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
}
