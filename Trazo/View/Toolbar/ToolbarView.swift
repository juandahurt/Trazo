//
//  ToolbarView.swift
//  Trazo
//
//  Created by apolo on 10/05/25.
//

import UIKit

class ToolbarView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 30
        stackView.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        return stackView
    }()
    
    private lazy var brushSizeSlider: UIView = {
        buildSliderWith(imageNamed: "circle.fill")
    }()
    
    private lazy var brushOpacitySlider: UIView = {
        buildSliderWith(imageNamed: "circle.tophalf.filled.inverse")
    }()
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addBlur()
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        layer.cornerRadius = 16
        backgroundColor = .init(
            red: 0.172,
            green: 0.172,
            blue: 0.172,
            alpha: 0.7
        )
        
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        layer.borderWidth = 1
        
        setupStackView()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(brushSizeSlider)
        stackView.addArrangedSubview(brushOpacitySlider)
        
        NSLayoutConstraint.activate([
            brushSizeSlider.heightAnchor
                .constraint(equalTo: brushOpacitySlider.heightAnchor, multiplier: 1)
        ])
        
        stackView.makeEgdes(equalTo: self)
    }
    
    private func buildSliderWith(imageNamed imageName: String) -> UIView {
        let slider = Slider(
            value: 20,
            minimumValue: 4,
            maximumValue: 30
        )
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.addArrangedSubview(slider)
        
        let image = UIImage(systemName: imageName)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .init(
            red: 0.85,
            green: 0.85,
            blue: 0.85,
            alpha: 0.8
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor
                .constraint(equalTo: imageView.widthAnchor, multiplier: 1)
        ])
        
        return stackView
    }
}
