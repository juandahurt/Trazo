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
    
    init(layer: Layer) {
        self.layer = layer
    }
}
