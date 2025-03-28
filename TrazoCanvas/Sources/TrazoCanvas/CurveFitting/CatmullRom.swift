//
//  CatmullRom.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 27/03/25.
//

import simd
import TrazoCore

class CatmullRom: CurveFittingAlgorithm {
    struct CatmullRomAnchorPoints {
        let p0: Vector2
        let p1: Vector2
        let p2: Vector2
        let p3: Vector2
    }
    
    struct Segment {
        let a, b, c, d: Vector2
        let p1p2Dist: Float
    }
    
    var alpha: Float = 0.5
    var tension: Float = 0.0
    
    private func generatePoints(forSegment segment: Segment) -> [DrawablePoint] {
        var points: [DrawablePoint] = []
        let steps = Int(segment.p1p2Dist)
        
        for i in 0..<steps {
            let t = Float(i) / Float(steps)
            let newPointPos = segment.a * pow(t, 3) +
            segment.b * pow(t, 2) +
            segment.c * t +
            segment.d
            
            points.append(.init(position: newPointPos))
        }
        
        return points
    }
    
    private func generateSegment(anchorPoints: CatmullRomAnchorPoints) -> Segment {
        let p0 = anchorPoints.p0
        let p1 = anchorPoints.p1
        let p2 = anchorPoints.p2
        let p3 = anchorPoints.p3
        
        let t0: Float = 0.0
        let t1 = t0 + pow(distance(p0, p1), alpha)
        let t2 = t1 + pow(distance(p1, p2), alpha)
        let t3 = t2 + pow(distance(p2, p3), alpha)
        
        let m1a = (1 - tension) * (t2 - t1)
        let m1b = ((p1 - p0) / (t1 - t0) - (p2 - p0) / (t2 - t0) + (p2 - p1) / (t2 - t1))
        let m1 = m1a * m1b
        
        let m2a = (1 - tension) * (t2 - t1)
        let m2b = ((p2 - p1) / (t2 - t1) - (p3 - p1) / (t3 - t1) + (p3 - p2) / (t3 - t2))
        let m2 = m2a * m2b
        
        return .init(
            a: 2 * (p1 - p2) + m1 + m2,
            b: -3 * (p1 - p2) - m1 - m1 - m2,
            c: m1,
            d: p1,
            p1p2Dist: distance(p1, p2)
        )
    }
    
    func generateDrawablePoints(anchorPoints: CatmullRomAnchorPoints) -> [DrawablePoint] {
        let segment = generateSegment(anchorPoints: anchorPoints)
        return generatePoints(forSegment: segment)
    }
}
