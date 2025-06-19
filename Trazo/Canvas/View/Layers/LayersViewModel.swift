//
//  LayersViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/04/25.
//

import Combine
import CoreGraphics
import TrazoCanvas
import TrazoEngine

@MainActor
protocol LayersViewModelObserver: AnyObject {
    func didSelectLayer(atIndex index: Int)
    func didItentToggleVisibilityOfLayer(atIndex index: Int)
}

@MainActor
class LayersViewModel {
    weak var observer: LayersViewModelObserver?
    
    private(set) var sections: [LayerSection] = []
    private var previews: [CGImage] = []
    
    var layerUpdateSubject = PassthroughSubject<Int, Never>()
    var applySnapshotSubject = PassthroughSubject<Void, Never>()
    
    func intentToggleVisibilityOfLayer(atIndex index: Int) {
        observer?.didItentToggleVisibilityOfLayer(atIndex: index)
    }
    
    func selectLayer(atIndex index: Int) {
        observer?.didSelectLayer(atIndex: index)
    }
}

extension LayersViewModel: ViewModelObserver {
    func didLoad(layers: [TrazoLayer]) {
        sections = [
            .init(items: [
                LayerTitleItem(title: "Layers")
            ]),
            .init(
                items: layers.map {
                    LayerListItem(
                        isVisible: $0.isVisible,
                        isSelected: $0.isSelected,
                        name: $0.title,
                        previewImage: $0.layer.texture.cgImage()
                    )
                }
            )
        ]
    }

    func didUpdate(layer: TrazoLayer, atIndex index: Int) {
        guard sections.count > 1 else { return }
        guard let item = sections[1].items[index] as? LayerListItem else {
            return
        }
        sections[1].items[index] = LayerListItem(
            isVisible: layer.isVisible,
            isSelected: layer.isSelected,
            name: layer.title,
            previewImage: item.previewImage
        )
        
        applySnapshotSubject.send(())
    }
    
    func didUpdateTexture(_ texture: Texture, atIndex index: Int) {
        guard sections.count > 1 else { return }
        guard let item = sections[1].items[index] as? LayerListItem else {
            return
        }
        
        item.id = .init()
        item.previewImage = texture.cgImage()
        
        sections[1].items[index] = item
        
        applySnapshotSubject.send(())
    }
}
