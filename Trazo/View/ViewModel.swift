//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import Combine
import UIKit
import TrazoCanvas

@MainActor
class ViewModel {
    private var isCanvasLoaded = false
    private var canvas = TrazoCanvas()
    
    var canvasView: UIView {
        canvas.canvasView
    }
    
    func viewDidLayoutSubviews() {
        guard !isCanvasLoaded else { return }
        canvas.load()
        isCanvasLoaded = true
    }
}
