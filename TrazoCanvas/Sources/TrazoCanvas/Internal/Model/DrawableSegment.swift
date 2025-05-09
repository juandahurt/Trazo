//
//  DrawableSegment.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 1/05/25.
//

import TrazoEngine

struct DrawableSegment {
    var pointsCount: Int
    var points: [DrawablePoint]
}

extension DrawableSegment {
    static var empty: DrawableSegment { DrawableSegment(pointsCount: 0, points: []) }
}
