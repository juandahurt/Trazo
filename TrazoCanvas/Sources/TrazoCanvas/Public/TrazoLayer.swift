//
//  TrazoLayer.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 13/04/25.
//

import TrazoEngine

@MainActor
public class TrazoLayer {
    var layer: Layer
    public var isVisible: Bool {
        layer.isVisible
    }
    public var title: String {
        layer.title
    }
    public internal(set) var isSelected: Bool
    
    init(layer: Layer, isSelected: Bool) {
        self.layer = layer
        self.isSelected = isSelected
    }
}
