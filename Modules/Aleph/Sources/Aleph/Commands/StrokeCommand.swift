import Foundation
import Tartarus

class StrokeCommand: Commandable {
    let touch: Touch
    
    init(touch: Touch) {
        self.touch = touch
    }
    
    func execute(context: Context) {
        var touch = touch
        touch.location = touch.location.applying(context.cameraMatrix.inverse)
        
        switch touch.phase {
        case .began:
            context.activeStroke = .init()
            context.activeStroke?.touches.append(touch)
        case .moved:
            guard let activeStroke = context.activeStroke else { return }
            context.activeStroke?.touches.append(touch)
            guard activeStroke.touches.count >= 3 else { return }
            
            if activeStroke.touches.count == 3 {
                if let segment = findFirstSegment(ctx: context), !segment.points.isEmpty {
                    context.pendingPasses.append(
                        StrokePass(segments: [segment])
                    )
                }
            }
            
            if activeStroke.touches.count > 3 {
                if let segment = findMidSegment(ctx: context), !segment.points.isEmpty {
                    context.pendingPasses.append(
                        StrokePass(segments: [segment])
                    )
                }
            }
        case .ended, .cancelled:
            context.activeStroke?.touches.append(touch)
            guard let activeStroke = context.activeStroke else { return }
            
            if activeStroke.touches.count > 3 {
                if let segment = findMidSegment(ctx: context), !segment.points.isEmpty {
                    context.pendingPasses.append(
                        StrokePass(segments: [segment])
                    )
                }
            }
            
            if activeStroke.touches.count > 2 {
                if let segment = findLastSegment(ctx: context), !segment.points.isEmpty {
                    context.pendingPasses.append(
                        StrokePass(segments: [segment])
                    )
                }
            }
        default: break
        }
        
        // merge layers after drawing
        context.pendingPasses.append(MergePass())
    }
    
    private func findFirstSegment(ctx: Context) -> StrokeSegment? {
        guard let activeStroke = ctx.activeStroke else { return nil }
        let curve = BezierCurve(
            p0: activeStroke.touches[0].location,
            p1: activeStroke.touches[0].location,
            p2: activeStroke.touches[1].location,
            p3: activeStroke.touches[2].location
        )
        return segment(for: curve, ctx: ctx)
    }
    
    private func findMidSegment(ctx: Context) -> StrokeSegment? {
        guard let activeStroke = ctx.activeStroke else { return nil }
        let index = activeStroke.touches.count - 3
        let curve = BezierCurve(
            p0: activeStroke.touches[index - 1].location,
            p1: activeStroke.touches[index].location,
            p2: activeStroke.touches[index + 1].location,
            p3: activeStroke.touches[index + 2].location
        )
        return segment(for: curve, ctx: ctx)
    }
    
    private func findLastSegment(ctx: Context) -> StrokeSegment? {
        guard let activeStroke = ctx.activeStroke else { return nil }
        let index = activeStroke.touches.count - 1
        let curve = BezierCurve(
            p0: activeStroke.touches[index - 1].location,
            p1: activeStroke.touches[index - 1].location,
            p2: activeStroke.touches[index].location,
            p3: activeStroke.touches[index].location
        )
        return segment(for: curve, ctx: ctx)
    }
   
    private func segment(for curve: BezierCurve, ctx: Context) -> StrokeSegment {
        var segment = StrokeSegment()
        // find the correct `t` values along the curve
        var currT: Float = 0
        let scale = ctx.cameraMatrix.scale
        let spacing: Float = 10
        let pointSize: Float = 10
        var prevPoint = curve.point(at: 0)
        while let t = findTForNextPoint(
            in: curve,
            startingAt: currT,
            spaceBetweenPoints: spacing,
            ctx: ctx
        ) {
            let currentPoint = curve.point(at: t)
            let dir = currentPoint - prevPoint
            let angle = atan2(dir.x, dir.y)
            segment.add(
                point: .init(
                    position: [currentPoint.x, currentPoint.y],
                    size: pointSize,
                    opacity: 1,
                    angle: 0
                ),
                transform: ctx.cameraMatrix
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
        ctx: Context
    ) -> Float? {
        guard let activeStroke = ctx.activeStroke else { return nil }
        let targetLength: Float = activeStroke.offset == 0 ? spaceBetweenPoints : activeStroke.offset
        let lengthToTheEndOfSegment = curve.length(from: t0, to: 1)
        
        if lengthToTheEndOfSegment < targetLength {
            // it exceeds the length to the end of the segment
            // this difference will be used as target distance in the next segment
            activeStroke.offset = targetLength - lengthToTheEndOfSegment
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
                activeStroke.offset = 0
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
