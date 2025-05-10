//
//  Slider.swift
//  Trazo
//
//  Created by Juan Hurtado on 9/05/25.
//

import UIKit

class Slider: UIControl {
    var initialValue: CGFloat = 0.0
    var minimumValue: CGFloat = 0.0
    var maximumValue: CGFloat = 1.0
    private(set) var value: CGFloat = 0 {
        didSet {
            if value < minimumValue { value = minimumValue; return }
            if value > maximumValue { value = maximumValue; return }
            
            updateHeightConstraint()
            sendActions(for: .valueChanged)
        }
    }
    private let cornerRadius: CGFloat = 14
    
    private lazy var progressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(
            red: 0.639,
            green: 0.639,
            blue: 0.639,
            alpha: 1
        )
        return view
    }()
    
    private var progressViewHeightConstraint: NSLayoutConstraint?
    
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
            red: 0.137,
            green: 0.137,
            blue: 0.137,
            alpha: 1
        )
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
            .constraint(equalToConstant: 60)
        progressViewHeightConstraint?.isActive = true
        
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
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        updateValue(forLocation: location)
    }
}
