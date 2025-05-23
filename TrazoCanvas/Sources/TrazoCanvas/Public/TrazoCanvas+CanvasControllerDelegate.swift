//
//  TrazoCanvas+CanvasControllerDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 14/04/25.
//

import TrazoEngine

extension TrazoCanvas: CanvasControllerDelegate {
    func didLoadLayers(_ layers: [Layer], currentLayerIndex: Int) {
        delegate?.canvas(self, didLoadLayers: layers.indices.map { index in
            .init(layer: layers[index], isSelected: index == currentLayerIndex)
        })
    }
    
    func didUpdateLayer(_ layer: Layer, atIndex index: Int, currentLayerIndex: Int) {
        delegate?.canvas(
            self,
            didUpdateLayer: .init(layer: layer, isSelected: index == currentLayerIndex),
            atIndex: index
        )
    }
    
    func didUpdateTexture(_ texture: Texture, ofLayerAtIndex index: Int) {
        delegate?.canvas(
            self,
            didUpdateTexture: texture,
            ofLayerAtIndex: index
        )
    }
}
