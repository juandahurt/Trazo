//
//  LayerSection.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/05/25.
//

import Foundation

class LayerSection: Hashable {
    var id: UUID
    var items: [LayerItem]
    
    init(id: UUID = .init(), items: [LayerItem]) {
        self.id = id
        self.items = items
    }
    
    static func ==(lhs: LayerSection, rhs: LayerSection) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
