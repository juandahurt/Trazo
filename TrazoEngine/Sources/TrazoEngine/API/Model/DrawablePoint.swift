//
//  DrawablePoint.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 28/03/25.
//

import TrazoCore

public struct DrawablePoint {
    public var position: Vector2
    public var size: Float
    
    public init(position: Vector2, size: Float) {
        self.position = position
        self.size = size
    }
    // TODO: add opacity, etc
}
