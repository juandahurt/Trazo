import Tartarus

class StrokeGenerator {
    private var touches: [Touch] = []
    
    func add(_ touch: Touch) {
        touches.append(touch)
    }
    
    func generateSegmentsForLastTouch(ctm: Transform) -> [StrokeSegment] {
        guard let touch = touches.last else { return [] }
        print(touch.phase)
        switch touch.phase {
        case .moved:
            guard touches.count >= 3 else { return [] }
            if touches.count == 3 {
                return [findFirstSegment(ctm: ctm)]
            } else {
                return [findMiddleSegment(ctm: ctm)]
            }
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
    
    private func segment(for curve: BezierCurve, ctm: Transform) -> StrokeSegment {
        let n = 10 // number of points
        var points = [DrawablePoint]()
        for i in 0..<n {
            let t = Float(i) / Float(n)
            let position = curve.point(at: t)
            points.append(
                .init(
                    position: [position.x, position.y],
                    size: 10
                )
            )
        }
        return .init(points: points)
    }
}
