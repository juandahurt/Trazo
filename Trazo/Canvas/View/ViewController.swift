//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import Combine
import UIKit

import TCanvas

class ViewController: UIViewController {
    var brush = TCBrush.normal
    let canvas: TCanvas
    var selectedTool: TCToolType
    
    private var brushItem: UIBarButtonItem!
    private var eraserItem: UIBarButtonItem!
    
    override var prefersStatusBarHidden: Bool {
        true
    }

    required init?(coder: NSCoder) {
        let canvasConfig = TCConfig(isTransformEnabled: true, brush: brush)
        canvas = .init(config: canvasConfig)
        selectedTool = canvas.selectedTool
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        canvas.load(in: view)
        
        view.backgroundColor = .init(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        setupBrushPropertiesView()
        setupToolbar()
    }
    
    func setupToolbar() {
        let appearence = UIToolbarAppearance()
        appearence.backgroundColor = .black.withAlphaComponent(0.85)
        
        let toolbar = UIToolbar()
        toolbar.standardAppearance = appearence
        toolbar.scrollEdgeAppearance = appearence
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        eraserItem = UIBarButtonItem(
            image: .init(systemName: "eraser.fill"),
            style: .plain,
            target: self,
            action: #selector(onEraserItemTap)
        )
        eraserItem.tintColor = .white.withAlphaComponent(selectedTool == .erase ? 1 : 0.4)
        brushItem = UIBarButtonItem(
            image: .init(systemName: "paintbrush.pointed.fill"),
            style: .plain,
            target: self,
            action: #selector(onBrushItemTap)
        )
        brushItem.tintColor = .white.withAlphaComponent(selectedTool == .draw ? 1 : 0.4)
        toolbar.setItems([space, brushItem, eraserItem, space], animated: false)
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    func setupBrushPropertiesView() {
        let brushPropertiesView = BrushPropertiesView()
        
        brushPropertiesView.onOpacityChange = { [weak self] in
            guard let self else { return }
            brush.opacity = $0
            canvas.updateBrush(with: brush)
        }
        brushPropertiesView.onSizeChange = { [weak self] in
            guard let self else { return }
            brush.size = $0
            canvas.updateBrush(with: brush)
        }
        
        view.addSubview(brushPropertiesView)
        
        NSLayoutConstraint.activate([
            brushPropertiesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            brushPropertiesView.widthAnchor.constraint(equalToConstant: 40),
            brushPropertiesView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            brushPropertiesView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension ViewController {
    @objc
    func onBrushItemTap() {
        selectedTool = .draw
        canvas.selectedTool = .draw
        brushItem.tintColor = brushItem.tintColor?.withAlphaComponent(1)
        eraserItem.tintColor = eraserItem.tintColor?.withAlphaComponent(0.5)
    }
    
    @objc
    func onEraserItemTap() {
        selectedTool = .erase
        canvas.selectedTool = .erase
        brushItem.tintColor = brushItem.tintColor?.withAlphaComponent(0.5)
        eraserItem.tintColor = eraserItem.tintColor?.withAlphaComponent(1)
    }
}
