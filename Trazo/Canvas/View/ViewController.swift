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
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
//    private lazy var eraserCheckbox: UISwitch = {
//        let checkbox = UISwitch()
//        checkbox.addTarget(self, action: #selector(onCheckboxToggle), for: .valueChanged)
//        return checkbox
//    }()
    
    private let toolbarView: ToolbarView = .init()

    required init?(coder: NSCoder) {
        let canvasConfig = TCConfig(isTransformEnabled: true, brush: brush)
        canvas = .init(config: canvasConfig)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        canvas.load(in: view)
        
        view.backgroundColor = .init(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        setupBrushPropertiesView()
        setupToolbarView()
//        view.addSubview(eraserCheckbox)
//        NSLayoutConstraint.activate([
//            eraserCheckbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            eraserCheckbox.topAnchor.constraint(equalTo: view.topAnchor)
//        ])
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
    
    private func setupToolbarView() {
        view.addSubview(toolbarView)
        
        NSLayoutConstraint.activate([
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.topAnchor.constraint(equalTo: view.topAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
//    @objc
//    func onCheckboxToggle() {
//        canvas.setTool(eraserCheckbox.isOn ? .erase : .draw)
//    }
}
