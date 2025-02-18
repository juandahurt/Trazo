//
//  Curve.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/02/25.
//

import CoreGraphics

struct Curve {
    var points: [CGPoint] = []
    var numPoints = 0
    
    mutating func addPoint(_ point: CGPoint) {
        points.append(point)
        numPoints += 1
    }
}
