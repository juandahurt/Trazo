//
//  LayerThumbnailView.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 14/04/25.
//

import UIKit
import TrazoEngine

public class LayerThumbnailView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public init() {
        super.init(frame: .zero)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(
            red: 0.2,
            green: 0.192,
            blue: 0.192,
            alpha: 1
        )
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public func update(using layer: TrazoLayer) {
        let cgImage = layer.layer.texture.cgImage()
        imageView.image = UIImage(cgImage: cgImage)
    }
}
