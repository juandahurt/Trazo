//
//  Vector2+CGPoint.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import CoreGraphics

public extension Vector2 {
    init(_ point: CGPoint) {
        self.init()
        x = Float(point.x)
        y = Float(point.y)
    }
}
