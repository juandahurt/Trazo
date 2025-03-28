//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import Combine
import UIKit
import TrazoCanvas
import TrazoCore

@MainActor
class ViewModel {
    private var isCanvasLoaded = false
    private var canvas: TrazoCanvas
   
    init() {
        let canvasDescriptor = TrazoCanvasDescriptor(
            brushColor: [0, 0, 0, 0.5]
        )
        canvas = .init(descriptor: canvasDescriptor)
    }
    
    var canvasView: UIView {
        canvas.canvasView
    }
    
    func viewDidLayoutSubviews() {
        guard !isCanvasLoaded else { return }
        canvas.load()
        isCanvasLoaded = true
    }
    
    func didSelectColor(_ color: UIColor) {
        guard let components = color.cgColor.components?.map({ Float($0) }) else { return }
        guard components.count == 4 else {
            print("Color components has a wrong format")
            return
        }
        canvas.setBrushColor([components[0], components[1], components[2], components[3]])
    }
}
