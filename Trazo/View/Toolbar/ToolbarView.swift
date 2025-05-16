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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        return stackView
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
        layer.cornerRadius = 4
        backgroundColor = .init(
            red: 0.094,
            green: 0.094,
            blue: 0.094,
            alpha: 0.3
        )
        
        setupStackView()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        stackView.makeEgdes(equalTo: self)
    }
}

extension ToolbarView {
    func addSliderAttribute(
        withValue value: CGFloat,
        minimumValue: CGFloat,
        maximumValue: CGFloat,
        imageName: String,
        onValueChange: ((CGFloat) -> Void)?
    ) {
        let attributeSlider = ToolbarAttributeSliderView(
            value: value,
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            imageName: imageName
        )
        attributeSlider.onValueChange = onValueChange
        
        stackView.addArrangedSubview(attributeSlider)
    }
}
