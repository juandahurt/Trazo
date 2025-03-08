//
//  CurveFittingStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 23/02/25.
//

import CoreGraphics
import simd

struct Segment {
    var a, b, c, d: CGPoint
    var p1p2Dist: CGFloat
}

class CurveFittingStep: WorkflowStep {
    func calculateSegment(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, alpha: CGFloat, tension: CGFloat) -> Segment {
        let t0: CGFloat = 0.0
        let t1 = t0 + pow(p0.distance(to: p1), alpha)
        let t2 = t1 + pow(p1.distance(to: p2), alpha)
        let t3 = t2 + pow(p2.distance(to: p3), alpha)
        
        let m1 = (1 - tension) * (t2 - t1) *
        ((p1 - p0) / (t1 - t0) - (p2 - p0) / (t2 - t0) + (p2 - p1) / (t2 - t1))
        
        let m2 = (1 - tension) * (t2 - t1) *
        ((p2 - p1) / (t2 - t1) - (p3 - p1) / (t3 - t1) + (p3 - p2) / (t3 - t2))
        
        return .init(
            a: 2 * (p1 - p2) + m1 + m2,
            b: -3 * (p1 - p2) - m1 - m1 - m2,
            c: m1,
            d: p1,
            p1p2Dist: p1.distance(to: p2)
        )
    }
    
    func addPointsFor(segment: Segment, state: inout CanvasState) {
        let steps = Int(segment.p1p2Dist)
        for i in 0..<steps {
            let t = CGFloat(i) / CGFloat(steps)
            let newPoint: CGPoint = segment.a * pow(t, 3) +
            segment.b * pow(t, 2) +
            segment.c * t +
            segment.d
            
            state.curveSectionToDraw.addPoint(newPoint)
        }
    }
    
    override func excecute(using state: inout CanvasState) {
        let curveNumPoints = state.currentCurve.numPoints
        let i = state.currentCurve.numPoints - 3
        guard curveNumPoints > 3 else { return }
        let p0 = state.currentCurve.points[i - 1]
        let p1 = state.currentCurve.points[i]
        let p2 = state.currentCurve.points[i + 1]
        let p3 = state.currentCurve.points[i + 2]
        
        let alpha = 0.5
        let tension = 0.0
        
        let segment = calculateSegment(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            alpha: alpha,
            tension: tension
        )
        addPointsFor(segment: segment, state: &state)
    }
}
