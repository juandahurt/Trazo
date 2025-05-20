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
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private let unselectedColor: UIColor = .init(
        red: 0.117,
        green: 0.117,
        blue: 0.117,
        alpha: 1
    )
    private let selectedColor: UIColor = .init(
        red: 0.184,
        green: 0.431,
        blue: 0.776,
        alpha: 1
    )
    
    var onVisibleButtonTap: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = unselectedColor
        selectionStyle = .none
        
        setupContainerView()
        setupVisibleButton()
        setupThumbnail()
        setupLabel()
    }
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 6),
            containerView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -6),
            containerView.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    private func setupVisibleButton() {
        containerView.addSubview(visibleButton)
        
        NSLayoutConstraint.activate([
            visibleButton.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 8),
            visibleButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupThumbnail() {
        containerView.addSubview(layerThumbnailView)
        
        NSLayoutConstraint.activate([
            layerThumbnailView.leadingAnchor
                .constraint(equalTo: visibleButton.trailingAnchor, constant: 10),
            layerThumbnailView.topAnchor
                .constraint(equalTo: containerView.topAnchor, constant: 4),
            layerThumbnailView.bottomAnchor
                .constraint(equalTo: containerView.bottomAnchor, constant: -4),
            layerThumbnailView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupLabel() {
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(
                equalTo: layerThumbnailView.trailingAnchor,
                constant: 16
            ),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
   
    func setup(using item: LayerListItem) {
        nameLabel.text = item.name
        nameLabel.textColor = item.isSelected ? .white : .gray
        containerView.backgroundColor = item.isSelected ? selectedColor : unselectedColor
        updateVisibleButton(isVisible: item.isVisible)
        layerThumbnailView.update(using: item.previewImage)
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
