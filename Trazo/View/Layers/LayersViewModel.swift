//
//  LayersViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/04/25.
//

import Combine
import TrazoCanvas

@MainActor
protocol LayersViewModelObserver: AnyObject {
    func didSelectLayer(atIndex index: Int)
}

@MainActor
class LayersViewModel {
    weak var observer: LayersViewModelObserver?
    var layerUpdateSubject = PassthroughSubject<Void, Never>()
    var layers: [TrazoLayer] = []
}

extension LayersViewModel: ViewModelObserver {
    func didLoad(layers: [TrazoLayer]) {
        self.layers = layers
    }

    func didUpdate(layer: TrazoLayer, atIndex index: Int) {
        layers[index] = layer
        layerUpdateSubject.send(())
    }
}
