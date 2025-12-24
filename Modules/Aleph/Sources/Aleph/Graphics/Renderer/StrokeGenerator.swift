import Foundation
import Tartarus

class StrokeSystem {
    private var touches: [Touch] = []
    private var stroke: [StrokeSegment] = []
    
    /// The difference of the target distance and the distance from a `t0` to
    /// the end of the segment in the last segment
    private var offset: Float = 0
    
    func add(_ touch: Touch) {
        touches.append(touch)
    }
    
    func reset() {
        touches = []
        stroke = []
    }
    
    func process(_ touch: Touch, ctm: Transform) -> [StrokeSegment] {
        if touch.phase == .began { reset() }
        add(touch)
        
        switch touch.phase {
        case .moved:
            guard touches.count >= 3 else { return [] }
            if touches.count == 3 {
                let segment = findFirstSegment(ctm: ctm)
                stroke.append(segment)
                return [segment]
            } else {
                let segment = findMiddleSegment(ctm: ctm)
                stroke.append(segment)
                return [segment]
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
            stroke.append(contentsOf: segments)
            return segments
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
        var segment = StrokeSegment()
        // if the stroke is empty, add the first point of the first curve
        if stroke.isEmpty {
            let pos = curve.point(at: 0)
            segment.add(
                point: .init(
                    position: [pos.x, pos.y],
                    size: 10,
                    opacity: 1
                ),
                ctm: ctm
            )
        }
        // find the correct `t` values along the curve
        var currT: Float = 0
        let scale = ctm.scale
        while let t = findTForNextPoint(
            in: curve,
            startingAt: currT,
            spaceBetweenPoints: 2 * scale,
        ) {
            let pos = curve.point(at: t)
            segment.add(
                point: .init(
                    position: [pos.x, pos.y],
                    size: 10,
                    opacity: 1
                ),
                ctm: ctm
            )
            currT = t
        }
        return segment
    }
    
    private func findTForNextPoint(
        in curve: BezierCurve,
        startingAt t0: Float,
        spaceBetweenPoints: Float
    ) -> Float? {
        let targetLength: Float = offset == 0 ? spaceBetweenPoints : offset
        let lengthToTheEndOfSegment = curve.length(from: t0, to: 1)
        
        if lengthToTheEndOfSegment < targetLength {
            // it exceeds the length to the end of the segment
            // this difference will be used as target distance in the next segment
            offset = targetLength - lengthToTheEndOfSegment
            return nil
        }
        
        let numberOfTimesToBisect = 20
        var bottom: Float = t0
        var top: Float = 1
        var mid: Float = bottom + ((top - bottom) / 2)

        for _ in 0..<numberOfTimesToBisect {
            // it doesn't necesarly need to loop that number of times,
            // most of the times will get the correct value way before that
            // number of iterations
            let length = curve.length(from: t0, to: mid)
            let diff = abs(length - targetLength)
            if diff <= 0.5 {
                offset = 0
                return mid
            }
            if length > targetLength {
                // move downwards
                top = mid
                mid = bottom + ((top - bottom) / 2)
            }
            if length < targetLength {
                // move upwards
                bottom = mid
                mid += ((top - mid) / 2)
            }
        }
        return nil
    }
}
