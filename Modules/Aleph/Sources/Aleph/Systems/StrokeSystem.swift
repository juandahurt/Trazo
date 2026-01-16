import Foundation
import Tartarus

class StrokeSystem {
    func update(ctx: inout SceneContext, touch: Touch) {
        // 1. store the touch
        ctx.strokeContext.touches.append(touch)
        print(ctx.strokeContext.touches.count)
        
        switch touch.phase {
        case .moved:
            guard ctx.strokeContext.touches.count >= 3 else { return }
            if ctx.strokeContext.touches.count == 3 {
                let segment = findFirstSegment(ctx: &ctx)
                ctx.strokeContext.segments.append(segment)
            } else {
                let segment = findMiddleSegment(ctx: &ctx)
                ctx.strokeContext.segments.append(segment)
            }
        case .cancelled, .ended:
            ctx.strokeContext.touches = []
            ctx.strokeContext.offset = 0
        default: break
        }
    }
    
    private func findMiddleSegment(ctx: inout SceneContext) -> StrokeSegment {
        let index = ctx.strokeContext.touches.count - 3
        let curve = BezierCurve(
            p0: ctx.strokeContext.touches[index - 1].location,
            p1: ctx.strokeContext.touches[index    ].location,
            p2: ctx.strokeContext.touches[index + 1].location,
            p3: ctx.strokeContext.touches[index + 2].location
        )
        return segment(for: curve, ctx: &ctx)
    }
    
    private func findFirstSegment(ctx: inout SceneContext) -> StrokeSegment {
        let curve = BezierCurve(
            p0: ctx.strokeContext.touches[0].location,
            p1: ctx.strokeContext.touches[0].location,
            p2: ctx.strokeContext.touches[1].location,
            p3: ctx.strokeContext.touches[2].location
        )
        return segment(for: curve, ctx: &ctx)
    }
    
    private func findLastSegment(ctx: inout SceneContext) -> StrokeSegment {
        let index = ctx.strokeContext.touches.count - 1
        let curve = BezierCurve(
            p0: ctx.strokeContext.touches[index - 1].location,
            p1: ctx.strokeContext.touches[index - 1].location,
            p2: ctx.strokeContext.touches[index].location,
            p3: ctx.strokeContext.touches[index].location
        )
        return segment(for: curve, ctx: &ctx)
    }
    
    private func segment(for curve: BezierCurve, ctx: inout SceneContext) -> StrokeSegment {
        var segment = StrokeSegment()
        // find the correct `t` values along the curve
        var currT: Float = 0
        let scale = ctx.renderContext.transform.scale
        var prevPoint = curve.point(at: 0)
        while let t = findTForNextPoint(
            in: curve,
            startingAt: currT,
            spaceBetweenPoints: ctx.strokeContext.brush.spacing * scale,
            ctx: &ctx
        ) {
            let currentPoint = curve.point(at: t)
            let dir = currentPoint - prevPoint
            let angle = atan2(dir.x, dir.y)
            segment.add(
                point: .init(
                    position: [currentPoint.x, currentPoint.y],
                    size: ctx.strokeContext.brush.pointSize,
                    opacity: ctx.strokeContext.brush.opacity,
                    angle: angle
                ),
                transform: ctx.renderContext.transform
            )
            currT = t
            prevPoint = currentPoint
        }
        return segment
    }
    
    private func findTForNextPoint(
        in curve: BezierCurve,
        startingAt t0: Float,
        spaceBetweenPoints: Float,
        ctx: inout SceneContext
    ) -> Float? {
        let targetLength: Float = ctx.strokeContext.offset == 0 ? spaceBetweenPoints : ctx.strokeContext.offset
        let lengthToTheEndOfSegment = curve.length(from: t0, to: 1)
        
        if lengthToTheEndOfSegment < targetLength {
            // it exceeds the length to the end of the segment
            // this difference will be used as target distance in the next segment
            ctx.strokeContext.offset = targetLength - lengthToTheEndOfSegment
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
                ctx.strokeContext.offset = 0
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
