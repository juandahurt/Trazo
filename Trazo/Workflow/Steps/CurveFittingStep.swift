//
//  CurveFittingStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 23/02/25.
//

import TrazoCore

struct Segment {
    var a, b, c, d: vector_t
    var p1p2Dist: Float
}

class CurveFittingStep: WorkflowStep {
    func calculateSegment(
        p0: vector_t,
        p1: vector_t,
        p2: vector_t,
        p3: vector_t,
        alpha: Float,
        tension: Float
    ) -> Segment {
        let t0: Float = 0.0
        let t1 = t0 + pow(p0.distance_to(p1), alpha)
        let t2 = t1 + pow(p1.distance_to(p2), alpha)
        let t3 = t2 + pow(p2.distance_to(p3), alpha)
        
        let m1 = (1 - tension) * (t2 - t1) *
        ((p1 - p0) / (t1 - t0) - (p2 - p0) / (t2 - t0) + (p2 - p1) / (t2 - t1))

        let m2 = (1 - tension) * (t2 - t1) *
        ((p2 - p1) / (t2 - t1) - (p3 - p1) / (t3 - t1) + (p3 - p2) / (t3 - t2))
        
        return .init(
            a: 2 * (p1 - p2) + m1 + m2,
            b: -3 * (p1 - p2) - m1 - m1 - m2,
            c: m1,
            d: p1,
            p1p2Dist: p1.distance_to(p2)
        )
    }
    
    func addPointsFor(segment: Segment, state: inout CanvasState) {
        let steps = Int(segment.p1p2Dist)
        for i in 0..<steps {
            let t = Float(i) / Float(steps)
            let newPoint: vector_t = segment.a * pow(t, 3) +
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
        
        let alpha: Float = 0.5
        let tension: Float = 0.0
        
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
