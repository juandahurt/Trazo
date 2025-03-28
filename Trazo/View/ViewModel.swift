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
   
    private(set) var initialBrushColor: UIColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    private(set) var initialBrushSize: Float = 5
    private(set) var minBrushSize: Float = 3
    private(set) var maxBrushSize: Float = 30
    
    init() {
        let canvasDescriptor = TrazoCanvasDescriptor(
            brushColor: initialBrushColor.toVector4(),
            brushSize: initialBrushSize
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
        canvas.setBrushColor(color.toVector4())
    }
    
    func didBrushSizeChange(_ value: Float) {
        canvas.setBrushSize(value)
    }
}
