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
import TrazoEngine

@MainActor
protocol ViewModelObserver: AnyObject {
    func didLoad(layers: [TrazoLayer])
    func didUpdate(layer: TrazoLayer, atIndex index: Int)
    func didUpdateTexture(_ texture: Texture, atIndex index: Int)
}

@MainActor
class ViewModel {
    private var isCanvasLoaded = false
    private var canvas: TrazoCanvas
   
    private(set) var initialBrushColor: UIColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    private(set) var initialBrushSize: Float = 10
    private(set) var minBrushSize: Float = 3
    private(set) var maxBrushSize: Float = 30
    let initialBrushOpacity: Float = 1
    
    weak var observer: ViewModelObserver?

    init() {
        let canvasDescriptor = TrazoCanvasDescriptor(
            brushColor: initialBrushColor.toVector4(),
            brushSize: initialBrushSize,
            brushOpacity: initialBrushOpacity
        )
        canvas = .init(descriptor: canvasDescriptor)
        canvas.delegate = self
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
    
    func didBrushOpacityChange(_ value: Float) {
        canvas.setBrushOpacity(value)
    }
}

extension ViewModel: TrazoCanvasDelegate {
    func canvas(
        _ canvas: TrazoCanvas,
        didLoadLayers layers: [TrazoLayer]
    ) {
        observer?.didLoad(layers: layers)
    }
    
    func canvas(
        _ canvas: TrazoCanvas,
        didUpdateLayer layer: TrazoLayer,
        atIndex index: Int
    ) {
        observer?.didUpdate(layer: layer, atIndex: index)
    }
    
    func canvas(
        _ canvas: TrazoCanvas,
        didUpdateTexture texture: Texture,
        ofLayerAtIndex index: Int
    ) {
        observer?.didUpdateTexture(texture, atIndex: index)
    }
}

extension ViewModel: LayersViewModelObserver {
    func didSelectLayer(atIndex index: Int) {
        canvas.setCurrentLayer(index)
    }
    
    func didItentToggleVisibilityOfLayer(atIndex index: Int) {
        canvas.toggleVisiblity(ofLayerAtIndex: index)
    }
}
