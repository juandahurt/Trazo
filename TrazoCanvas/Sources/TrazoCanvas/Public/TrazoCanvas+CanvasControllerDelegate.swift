//
//  TrazoCanvas+CanvasControllerDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 14/04/25.
//

extension TrazoCanvas: CanvasControllerDelegate {
    func didLoadLayers(_ layers: [Layer], currentLayerIndex: Int) {
        delegate?.canvas(self, didLoadLayers: layers.map {
            .init(layer: $0, isSelected: false)
        })
    }
    
    func didUpdateLayer(_ layer: Layer, atIndex index: Int, currentLayerIndex: Int) {
        delegate?.canvas(
            self,
            didUpdateLayer: .init(layer: layer, isSelected: index == currentLayerIndex),
            atIndex: index
        )
    }
}
