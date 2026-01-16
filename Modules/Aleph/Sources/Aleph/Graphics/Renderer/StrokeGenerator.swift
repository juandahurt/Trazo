//import Foundation
//import Tartarus
//
//class StrokeSystem {
//    private var touches: [Touch] = []
//    private var stroke: [StrokeSegment] = []
//    
//    /// The difference of the target distance and the distance from a `t0` to
//    /// the end of the segment in the last segment
//    private var offset: Float = 0
//    
//    func add(_ touch: Touch) {
//        touches.append(touch)
//    }
//    
//    func reset() {
//        touches = []
//        stroke = []
//        offset = 0
//    }
//    
//    func process(_ touch: Touch, brush: Brush, ctm: Transform) -> [StrokeSegment] {
//        if touch.phase == .began { reset() }
//        add(touch)
//        
//        switch touch.phase {
//        case .moved:
//            guard touches.count >= 3 else { return [] }
//            if touches.count == 3 {
//                let segment = findFirstSegment(brush: brush, ctm: ctm)
//                stroke.append(segment)
//                return [segment]
//            } else {
//                let segment = findMiddleSegment(brush: brush, ctm: ctm)
//                stroke.append(segment)
//                return [segment]
//            }
//        case .ended, .cancelled:
//            guard touches.count > 3 else { return [] }
//            var segments: [StrokeSegment] = []
//            // add the second-last curve
//            var secondLast = findMiddleSegment(brush: brush, ctm: ctm)
//            segments.append(secondLast)
//            // add the last curve
//            var last = findLastSegment(brush: brush, ctm: ctm)
//            segments.append(last)
//            stroke.append(contentsOf: segments)
//            return segments
//        default: break
//        }
//        
//        return []
//    }
//    
//    private func findMiddleSegment(brush: Brush, ctm: Transform) -> StrokeSegment {
//        let index = touches.count - 3
//        let curve = BezierCurve(
//            p0: touches[index - 1].location,
//            p1: touches[index    ].location,
//            p2: touches[index + 1].location,
//            p3: touches[index + 2].location
//        )
//        return segment(for: curve, brush: brush, ctm: ctm)
//    }
//    
//    private func findFirstSegment(brush: Brush, ctm: Transform) -> StrokeSegment {
//        let curve = BezierCurve(
//            p0: touches[0].location,
//            p1: touches[0].location,
//            p2: touches[1].location,
//            p3: touches[2].location
//        )
//        return segment(for: curve, brush: brush, ctm: ctm)
//    }
//    
//    private func findLastSegment(brush: Brush, ctm: Transform) -> StrokeSegment {
//        let index = touches.count - 1
//        let curve = BezierCurve(
//            p0: touches[index - 1].location,
//            p1: touches[index - 1].location,
//            p2: touches[index].location,
//            p3: touches[index].location
//        )
//        return segment(for: curve, brush: brush, ctm: ctm)
//    }
//    
//    private func segment(for curve: BezierCurve, brush: Brush, ctm: Transform) -> StrokeSegment {
//        var segment = StrokeSegment()
//        // find the correct `t` values along the curve
//        var currT: Float = 0
//        let scale = ctm.scale
//        var prevPoint = curve.point(at: 0)
//        while let t = findTForNextPoint(
//            in: curve,
//            startingAt: currT,
//            spaceBetweenPoints: brush.spacing * scale,
//        ) {
//            let currentPoint = curve.point(at: t)
//            let dir = currentPoint - prevPoint
//            let angle = atan2(dir.x, dir.y)
//            segment.add(
//                point: .init(
//                    position: [currentPoint.x, currentPoint.y],
//                    size: brush.pointSize,
//                    opacity: brush.opacity,
//                    angle: angle
//                ),
//                ctm: ctm
//            )
//            currT = t
//            prevPoint = currentPoint
//        }
//        return segment
//    }
//    
//    private func findTForNextPoint(
//        in curve: BezierCurve,
//        startingAt t0: Float,
//        spaceBetweenPoints: Float
//    ) -> Float? {
//        let targetLength: Float = offset == 0 ? spaceBetweenPoints : offset
//        let lengthToTheEndOfSegment = curve.length(from: t0, to: 1)
//        
//        if lengthToTheEndOfSegment < targetLength {
//            // it exceeds the length to the end of the segment
//            // this difference will be used as target distance in the next segment
//            offset = targetLength - lengthToTheEndOfSegment
//            return nil
//        }
//        
//        let numberOfTimesToBisect = 20
//        var bottom: Float = t0
//        var top: Float = 1
//        var mid: Float = bottom + ((top - bottom) / 2)
//
//        for _ in 0..<numberOfTimesToBisect {
//            // it doesn't necesarly need to loop that number of times,
//            // most of the times will get the correct value way before that
//            // number of iterations
//            let length = curve.length(from: t0, to: mid)
//            let diff = abs(length - targetLength)
//            if diff <= 0.5 {
//                offset = 0
//                return mid
//            }
//            if length > targetLength {
//                // move downwards
//                top = mid
//                mid = bottom + ((top - bottom) / 2)
//            }
//            if length < targetLength {
//                // move upwards
//                bottom = mid
//                mid += ((top - mid) / 2)
//            }
//        }
//        return nil
//    }
//}
