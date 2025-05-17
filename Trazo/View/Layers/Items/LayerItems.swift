//
//  LayerItems.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/05/25.
//

import Foundation

class LayerListItem: LayerItem {
    let isVisible: Bool
    let isSelected: Bool
    let name: String
    
    init(isVisible: Bool, isSelected: Bool, name: String) {
        self.isVisible = isVisible
        self.isSelected = isSelected
        self.name = name
    }
}

class LayerTitleItem: LayerItem {
    let title: String
    
    init(title: String) {
        self.title = title
    }
}

class LayerItem: Hashable {
    var id: UUID = .init()
    
    static func ==(lhs: LayerItem, rhs: LayerItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
