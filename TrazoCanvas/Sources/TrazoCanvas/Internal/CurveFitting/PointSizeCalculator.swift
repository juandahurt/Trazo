//
//  PointSizeCalculator.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 7/05/25.
//

import TrazoEngine

class PointSizeCalculator {
    func sizeOfPoint(v0: Float, v1: Float, t: Float) -> Float {
        let rawSize = v0 + t * (v1 - v0)
        // points should have a size of at least 3 points
        return max(rawSize, 2)
    }
    
    func updateSizes(
        ofPoints points: inout [DrawablePoint],
        pointCount: Int,
        v0: Float,
        v1: Float
    ) {
        for index in 0..<pointCount {
            let t = Float(index) / Float(pointCount)
            let size = sizeOfPoint(v0: v0, v1: v1, t: t)
            points[index].size = size
        }
    }
}
