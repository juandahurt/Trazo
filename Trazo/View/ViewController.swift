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
    let canvas: TCanvas
    
    override var prefersStatusBarHidden: Bool {
        true
    }

    required init?(coder: NSCoder) {
        let canvasConfig = TCConfig(
            brushSize: Config.brushSizeValue,
            brushOpacity: Config.brushOpacityValue
        )
        canvas = .init(config: canvasConfig)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        canvas.load(in: view)
        
        view.backgroundColor = .init(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        setupToolbar()
    }
    
    func setupToolbar() {
        let toolbar = ToolbarView()
        
        toolbar.onOpacityChange = { [weak self] in
            guard let self else { return }
            canvas.brushOpacity = $0
        }
        toolbar.onSizeChange = { [weak self] in
            guard let self else { return }
            canvas.brushSize = $0
        }
        
        canvas.brushOpacity = Config.brushOpacityValue
        canvas.brushSize = Config.brushSizeValue
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.widthAnchor.constraint(equalToConstant: 48),
            toolbar.heightAnchor.constraint(equalToConstant: 450),
            toolbar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
