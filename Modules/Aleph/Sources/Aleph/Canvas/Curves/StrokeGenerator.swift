import Tartarus

class StrokeGenerator {
    private var touches: [Touch] = []
    
    func add(_ touch: Touch) {
        touches.append(touch)
    }
    
    func reset() {
        touches = []
    }
    
    func generateSegmentsForLastTouch(ctm: Transform) -> [StrokeSegment] {
        guard let touch = touches.last else { return [] }
        switch touch.phase {
        case .moved:
            guard touches.count >= 3 else { return [] }
            if touches.count == 3 {
                return [findFirstSegment(ctm: ctm)]
            } else {
                return [findMiddleSegment(ctm: ctm)]
            }
        case .ended, .cancelled:
            guard touches.count > 3 else { return [] }
            var segments: [StrokeSegment] = []
            // add the second-last curve
            var segment = findMiddleSegment(ctm: ctm)
            segments.append(segment)
            // add the last curve
            segment = findLastSegment(ctm: ctm)
            segments.append(segment)
        default: break
        }
        
        return []
    }
    
    private func findMiddleSegment(ctm: Transform) -> StrokeSegment {
        let index = touches.count - 3
        let curve = BezierCurve(
            p0: touches[index - 1].location,
            p1: touches[index    ].location,
            p2: touches[index + 1].location,
            p3: touches[index + 2].location
        )
        return segment(for: curve, ctm: ctm)
    }
    
    private func findFirstSegment(ctm: Transform) -> StrokeSegment {
        let curve = BezierCurve(
            p0: touches[0].location,
            p1: touches[0].location,
            p2: touches[1].location,
            p3: touches[2].location
        )
        return segment(for: curve, ctm: ctm)
    }
    
    private func findLastSegment(ctm: Transform) -> StrokeSegment {
        let index = touches.count - 1
        let curve = BezierCurve(
            p0: touches[index - 1].location,
            p1: touches[index].location,
            p2: touches[index].location,
            p3: touches[index].location
        )
        return segment(for: curve, ctm: ctm)
    }
    
    private func segment(for curve: BezierCurve, ctm: Transform) -> StrokeSegment {
        let inverse = ctm.inverse
        let c0 = curve.c0.applying(inverse)
        let c1 = curve.c1.applying(inverse)
        let c2 = curve.c2.applying(inverse)
        let c3 = curve.c3.applying(inverse)
        let length =
            c0.dist(to: c1) +
            c1.dist(to: c2) +
            c2.dist(to: c3)
        let n = max(1, Int(length))  // number of points
        var segment = StrokeSegment()
        for i in 0..<n {
            let t = Float(i) / Float(n)
            let position = curve.point(at: t)
            segment.add(
                point: .init(
                    position: [position.x, position.y],
                    size: .random(in: 3...15),
                    opacity: .random(in: 0...0.2)
                ),
                ctm: ctm
            )
        }
        return segment
    }
}
