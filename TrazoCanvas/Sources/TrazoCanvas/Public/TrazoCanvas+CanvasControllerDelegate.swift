//
//  TrazoCanvas+CanvasControllerDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 14/04/25.
//

extension TrazoCanvas: CanvasControllerDelegate {
    func didLoadLayers(_ layers: [Layer]) {
        delegate?.canvas(self, didLoadLayers: layers.map { .init(layer: $0) })
    }
    
    func didUpdateLayer(_ layer: Layer, atIndex index: Int) {
        delegate?.canvas(self, didUpdateLayer: .init(layer: layer), atIndex: index)
    }
}
