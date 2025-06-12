//
//  Slider.swift
//  Trazo
//
//  Created by Juan Hurtado on 9/05/25.
//

import UIKit

class Slider: UIControl {
    private let initialValue: CGFloat
    private let minimumValue: CGFloat
    private let maximumValue: CGFloat
    private(set) var value: CGFloat
    private let cornerRadius: CGFloat = 10
    
    private var hasLayoutSubviewsOnce = false
    
    private lazy var progressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(
            red: 0.85,
            green: 0.85,
            blue: 0.85,
            alpha: 0.8
        )
        return view
    }()
    
    private var progressViewHeightConstraint: NSLayoutConstraint?
    
    init(
        value: CGFloat,
        minimumValue: CGFloat,
        maximumValue: CGFloat
    ) {
        initialValue = value
        self.value = value
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white.withAlphaComponent(0.1)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        setupProgressView()
    }
    
    private func setupProgressView() {
        addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        progressViewHeightConstraint = progressView.heightAnchor
            .constraint(equalToConstant: 0)
        progressViewHeightConstraint?.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !hasLayoutSubviewsOnce else { return }
        hasLayoutSubviewsOnce = true
        updateHeightConstraint()
    }
}

// MARK: - Value update
extension Slider {
    private func updateHeightConstraint() {
        let t = (value - minimumValue) / (maximumValue - minimumValue)
        progressViewHeightConstraint?.constant = t * bounds.height
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            layoutIfNeeded()
        }
    }
    
    private func updateValue(forLocation location: CGPoint) {
        // (1 - value) since the coordinates are flipped
        let t = min(1, max(0, 1 - (location.y / bounds.height)))
        value = minimumValue + t * (maximumValue - minimumValue)
    }
}

// MARK: - Touches
extension Slider {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        updateValue(forLocation: location)
        updateHeightConstraint()
        sendActions(for: .valueChanged)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        updateValue(forLocation: location)
        updateHeightConstraint()
        sendActions(for: .valueChanged)
    }
}
