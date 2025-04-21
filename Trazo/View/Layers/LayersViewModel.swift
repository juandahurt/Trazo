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
    func didItentToggleVisibilityOfLayer(atIndex index: Int)
}

@MainActor
class LayersViewModel {
    weak var observer: LayersViewModelObserver?
    
    private var isPresented = false
    
    private(set) var layers: [TrazoLayer] = []
    private(set) var layerIndicesToBeUpdated: [Int] = []
    
    var layerUpdateSubject = PassthroughSubject<Int, Never>()
    
    func viewDidAppear() {
        isPresented = true
    }
    
    func viewDidDisappear() {
        isPresented = false
    }
    
    func intentToggleVisibilityOfLayer(atIndex index: Int) {
        observer?.didItentToggleVisibilityOfLayer(atIndex: index)
    }
    
    func clearIndicesToBeUpdated() {
        layerIndicesToBeUpdated.removeAll()
    }
    
    func selectLayer(atIndex index: Int) {
        observer?.didSelectLayer(atIndex: index)
    }
}

extension LayersViewModel: ViewModelObserver {
    func didLoad(layers: [TrazoLayer]) {
        self.layers = layers
    }

    func didUpdate(layer: TrazoLayer, atIndex index: Int) {
        layers[index] = layer
        // only notify the view controller to update the table view
        // when it's in the view heirarchy
        if isPresented { layerUpdateSubject.send(index) }
    }
}
