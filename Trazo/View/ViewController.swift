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
    let canvas = TCanvas()
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override func viewDidLoad() {
        canvas.load(in: view)
        
        view.backgroundColor = .init(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        setupToolbar()
    }
    
    func setupToolbar() {
        let toolbar = ToolbarView()
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.widthAnchor.constraint(equalToConstant: 48),
            toolbar.heightAnchor.constraint(equalToConstant: 450),
            toolbar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
