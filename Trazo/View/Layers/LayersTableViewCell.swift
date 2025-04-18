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
    
    var onVisibleButtonTap: ((Bool) -> Void)?
    var isVisible = true
    
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
    
    func update(using layer: TrazoLayer) {
        visibleButton.setImage(.init(systemName: "checkmark.square.fill"), for: .normal)
        layerThumbnailView.update(using: layer)
    }
    
    @objc
    func visibleButtonAction() {
        isVisible = !isVisible
        onVisibleButtonTap?(isVisible)
    }
}
