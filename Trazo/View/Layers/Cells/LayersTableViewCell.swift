//
//  LayersTableViewCell.swift
//  Trazo
//
//  Created by Juan Hurtado on 12/04/25.
//

import UIKit
import TrazoCanvas

class LayersTableViewCell: UITableViewCell {
    private let layerThumbnailView: LayerThumbnailView = {
        let thumbnail = LayerThumbnailView()
        return thumbnail
    }()
    
    private lazy var visibleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button
            .addTarget(
                self,
                action: #selector(visibleButtonAction),
                for: .touchUpInside
            )
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    var onVisibleButtonTap: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = .init(
            red: 0.117,
            green: 0.117,
            blue: 0.117,
            alpha: 1
        )
        
        setupVisibleButton()
        setupThumbnail()
        setupLabel()
    }
    
    private func setupVisibleButton() {
        contentView.addSubview(visibleButton)
        
        NSLayoutConstraint.activate([
            visibleButton.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 16),
            visibleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupThumbnail() {
        contentView.addSubview(layerThumbnailView)
        
        NSLayoutConstraint.activate([
            layerThumbnailView.leadingAnchor
                .constraint(equalTo: visibleButton.trailingAnchor, constant: 10),
            layerThumbnailView.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 4),
            layerThumbnailView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -4),
            layerThumbnailView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupLabel() {
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(
                equalTo: layerThumbnailView.trailingAnchor,
                constant: 10
            ),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func update(using layer: TrazoLayer) {
        updateVisibleButton(isVisible: layer.isVisible)
        layerThumbnailView.update(using: layer)
        nameLabel.text = layer.title
    }
    
    func updateVisibleButton(isVisible: Bool) {
        let imageName = isVisible ? "checkmark.square.fill" : "square"
        visibleButton.setImage(.init(systemName: imageName), for: .normal)
    }
    
    @objc
    func visibleButtonAction() {
        onVisibleButtonTap?()
    }
}
