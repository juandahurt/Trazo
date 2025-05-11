//
//  ToolbarAttributeSliderView.swift
//  Trazo
//
//  Created by Juan Hurtado on 10/05/25.
//

import UIKit

class ToolbarAttributeSliderView: UIView {
    var onValueChange: ((CGFloat) -> Void)?
    
    private var slider: Slider?
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 4, left: 4, bottom: 4, right: 4)
        return stackView
    }()
    
    init(
        value: CGFloat,
        minimumValue: CGFloat,
        maximumValue: CGFloat,
        imageName: String
    ) {
        super.init(frame: .zero)
                
        setup()
        setupSlider(value: value, minimumValue: minimumValue, maximumValue: maximumValue)
        setupImage(named: imageName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        layer.cornerRadius = 4
        
        setupStackView()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupSlider(
        value: CGFloat,
        minimumValue: CGFloat,
        maximumValue: CGFloat
    ) {
        slider = .init(
            value: value,
            minimumValue: minimumValue,
            maximumValue: maximumValue
        )
        guard let slider else { return }
        
        slider.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        slider
            .addTarget(
                self,
                action: #selector(onSliderValueChange(_:)),
                for: .valueChanged
            )
        
        stackView.addArrangedSubview(slider)
        
        slider.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
    }
    
    private func setupImage(named name: String) {
        let image = UIImage(systemName: name)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .init(
            red: 0.2,
            green: 0.2,
            blue: 0.2,
            alpha: 1
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)

        stackView.addArrangedSubview(imageView)
        
        imageView.heightAnchor
            .constraint(
                equalTo: stackView.heightAnchor,
                multiplier: 0.15
            ).isActive = true
    }
    
    @objc
    func onSliderValueChange(_ sender: Slider) {
        onValueChange?(sender.value)
    }
}
