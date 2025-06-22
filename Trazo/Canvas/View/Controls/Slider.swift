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
    private let cornerRadius: CGFloat = 4
    private let handlerHeight: CGFloat = 4
    private let handlerWidthOffset: CGFloat = 2
    
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
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private let handlerView: UIView = {
        let topView = UIView()
        topView.backgroundColor = .white
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.layer.cornerRadius = 2
        return topView
    }()
    
    private var progressViewHeightConstraint: NSLayoutConstraint?
    private var handlerViewBottomAnchorConstraint: NSLayoutConstraint?
    
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
        
        setupProgressView()
        setupHandlerView()
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
    
    private func setupHandlerView() {
        addSubview(handlerView)
        
        NSLayoutConstraint.activate([
            handlerView.leadingAnchor
                .constraint(equalTo: leadingAnchor, constant: -handlerWidthOffset),
            handlerView.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: handlerWidthOffset),
            handlerView.heightAnchor.constraint(equalToConstant: handlerHeight)
        ])
        
        handlerViewBottomAnchorConstraint = handlerView.bottomAnchor
            .constraint(equalTo: bottomAnchor, constant: 0)
        handlerViewBottomAnchorConstraint?.isActive = true
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
        let newHeight = t * bounds.height
        progressViewHeightConstraint?.constant = newHeight
        
        handlerViewBottomAnchorConstraint?.constant = -min(
            newHeight,
            bounds.height - handlerHeight
        )
        
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
