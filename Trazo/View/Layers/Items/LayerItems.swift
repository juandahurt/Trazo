//
//  LayerItems.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/05/25.
//

import Foundation
import CoreGraphics

class LayerListItem: LayerItem {
    var isVisible: Bool
    var isSelected: Bool
    let name: String
    var previewImage: CGImage
    
    init(isVisible: Bool, isSelected: Bool, name: String, previewImage: CGImage) {
        self.isVisible = isVisible
        self.isSelected = isSelected
        self.name = name
        self.previewImage = previewImage
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
