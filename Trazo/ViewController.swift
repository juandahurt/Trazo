//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCanvasView()
    }
    
    func setupCanvasView() {
        let canvasView = CanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate(
            [
                canvasView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor
                ),
                canvasView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor
                ),
                canvasView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor
                ),
                canvasView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor
                ),
            ]
        )
    }
}

