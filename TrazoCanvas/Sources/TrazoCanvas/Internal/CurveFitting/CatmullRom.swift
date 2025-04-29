//
//  CatmullRom.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 27/03/25.
//

import simd
import TrazoCore
import TrazoEngine

class CatmullRom: CurveFittingAlgorithm {
    struct CatmullRomAnchorPoints {
        let p0: Vector2
        let p1: (location: Vector2, force: Float)
        let p2: (location: Vector2, force: Float)
        let p3: Vector2
    }
    
    struct Segment {
        let a, b, c, d: Vector2
        let pis: Int // points in segment
        let initialForce, finalForce: Float
    }
    
    var alpha: Float = 0.5
    var tension: Float = 0.0
    
    private func generatePoints(forSegment segment: Segment) -> [DrawablePoint] {
        var points: [DrawablePoint] = []
        
        for i in 0..<segment.pis {
            let t = Float(i) / Float(segment.pis)
            let newPointPos = segment.a * pow(t, 3) +
            segment.b * pow(t, 2) +
            segment.c * t +
            segment.d
            
            let rawSize = segment.initialForce + t * (
                segment.finalForce - segment.initialForce
            )
            // points should have a size of at least 3 points
            let size = max(rawSize, 3)
            
            points.append(.init(position: newPointPos, size: size))
        }
        
        return points
    }
    
    private func generateSegment(
        anchorPoints: CatmullRomAnchorPoints,
        scale: Float,
        brushSize: Float
    ) -> Segment {
        let p0 = anchorPoints.p0
        let p1 = anchorPoints.p1.location
        let p2 = anchorPoints.p2.location
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
        
        // the number of points in the segment will be given by the linear distance between
        // p1 and p2 divided by the scale. We use the scale beacuse the distance varies depending on it.
        
        return .init(
            a: 2 * (p1 - p2) + m1 + m2,
            b: -3 * (p1 - p2) - m1 - m1 - m2,
            c: m1,
            d: p1,
            pis: Int(distance(p1, p2) / scale),
            initialForce: anchorPoints.p1.force * brushSize,
            finalForce: anchorPoints.p2.force * brushSize
        )
    }
    
    func generateDrawablePoints(
        anchorPoints: CatmullRomAnchorPoints,
        scale: Float,
        brushSize: Float
    ) -> [DrawablePoint] {
        let segment = generateSegment(
            anchorPoints: anchorPoints,
            scale: scale,
            brushSize: brushSize
        )
        return generatePoints(forSegment: segment)
    }
}
