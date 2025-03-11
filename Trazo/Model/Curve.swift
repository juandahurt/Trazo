//
//  Curve.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/02/25.
//

import CoreGraphics
import TrazoCore

struct Curve {
    var points: [vector_t] = []
    var numPoints = 0
    
    mutating func addPoint(_ point: vector_t) {
        points.append(point)
        numPoints += 1
    }
}
