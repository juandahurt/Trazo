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
        var segments: [StrokeSegment] = []
        
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
                    segments.append(segment)
                }
            }
            
            if activeStroke.touches.count > 3 {
                if let segment = findMidSegment(ctx: context), !segment.points.isEmpty {
                    segments.append(segment)
                }
            }
        case .ended, .cancelled:
            context.activeStroke?.touches.append(touch)
            guard let activeStroke = context.activeStroke else { return }
            
            if activeStroke.touches.count > 3 {
                if let segment = findMidSegment(ctx: context), !segment.points.isEmpty {
                    segments.append(segment)
                }
            }
            
            if activeStroke.touches.count > 2 {
                if let segment = findLastSegment(ctx: context), !segment.points.isEmpty {
                    segments.append(segment)
                }
            }
        default: break
        }
        
        // merge layers after drawing
        let dirtyArea = segments.boundsUnion().clip(
            .init(
                x: 0,
                y: 0,
                width: context.canvasSize.width,
                height: context.canvasSize.height
            )
        )
        
        guard !segments.isEmpty else { return }
        context.pendingPasses.append(StrokePass(segments: segments))
        context.pendingPasses.append(MergePass(dirtyArea: dirtyArea))
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
        guard let activeStroke = ctx.activeStroke else { return segment }
        // find the correct `t` values along the curve
        var prevPoint = curve.point(at: 0)
        var dist = activeStroke.offset == 0 ? ctx.brush.spacing : activeStroke.offset
        while let t = findTForNextPoint(
            atDist: dist,
            in: curve,
            ctx: ctx
        ) {
            let currentPoint = curve.point(at: t)
            let dir = currentPoint - prevPoint
            let angle = atan2(dir.x, dir.y)
            segment.add(
                point: .init(
                    position: [currentPoint.x, currentPoint.y],
                    size: ctx.brush.pointSize,
                    opacity: ctx.brush.opacity,
                    angle: angle * .random(in: (-2 * .pi)...(2 * .pi))
                )
            )
            prevPoint = currentPoint
            dist += ctx.brush.spacing
        }
        return segment
    }
    
    private func findTForNextPoint(
        atDist dist: Float,
        in curve: BezierCurve,
        ctx: Context
    ) -> Float? {
        guard let activeStroke = ctx.activeStroke else { return nil }
        let distToTheEndOfSegment = curve.totalDistance
        
        if distToTheEndOfSegment < dist {
            // it exceeds the length to the end of the segment
            // this difference will be used as target distance in the next segment
            activeStroke.offset = dist - distToTheEndOfSegment
            return nil
        }
        activeStroke.offset = 0
        return curve.t(atDistance: dist)
    }
}
