import Foundation
import Tartarus

protocol System {
    func update(ctx: Context)
}

class StrokeSystem: System {
    private var unhandledTouches: [Touch] = []
    
    func push(_ touch: Touch) {
        unhandledTouches.append(touch)
    }
    
    func update(ctx: Context) {
        while var touch = unhandledTouches.popFirst() {
            touch.location = touch.location.applying(ctx.cameraMatrix.inverse)
            var segments: [StrokeSegment] = []
            
            switch touch.phase {
            case .began:
                ctx.strokeContext.activeStroke = .init()
                ctx.strokeContext.activeStroke?.add(touch: touch)
                ctx.strokeContext.setShouldClearStrokeGrid(true)
            case .moved:
                guard let activeStroke = ctx.strokeContext.activeStroke else { return }
                ctx.strokeContext.activeStroke?.add(touch: touch)
                guard activeStroke.touches.count >= 3 else { return }
                
                if activeStroke.touches.count == 3 {
                    if let segment = findFirstSegment(ctx: ctx), !segment.points.isEmpty {
                        segments.append(segment)
                    }
                }
                
                if activeStroke.touches.count > 3 {
                    if let segment = findMidSegment(ctx: ctx), !segment.points.isEmpty {
                        segments.append(segment)
                    }
                }
            case .ended, .cancelled:
                ctx.strokeContext.activeStroke?.add(touch: touch)
                guard let activeStroke = ctx.strokeContext.activeStroke else { return }
                
                if activeStroke.touches.count > 3 {
                    if let segment = findMidSegment(ctx: ctx), !segment.points.isEmpty {
                        segments.append(segment)
                    }
                }
                
                if activeStroke.touches.count > 2 {
                    if let segment = findLastSegment(ctx: ctx), !segment.points.isEmpty {
                        segments.append(segment)
                    }
                }
                ctx.strokeContext.setShouldUpdateLayerGrid(true)
            default: break
            }
            guard !segments.isEmpty else { return }
            
            ctx.strokeContext.addSegments(segments)
            ctx.renderContext.enqueue(.stroke)
        }
    }
    
    private func findFirstSegment(ctx: Context) -> StrokeSegment? {
        guard let activeStroke = ctx.strokeContext.activeStroke else { return nil }
        let curve = BezierCurve(
            p0: activeStroke.touches[0].location,
            p1: activeStroke.touches[0].location,
            p2: activeStroke.touches[1].location,
            p3: activeStroke.touches[2].location
        )
        return segment(for: curve, ctx: ctx)
    }
    
    private func findMidSegment(ctx: Context) -> StrokeSegment? {
        guard let activeStroke = ctx.strokeContext.activeStroke else { return nil }
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
        guard let activeStroke = ctx.strokeContext.activeStroke else { return nil }
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
        guard let activeStroke = ctx.strokeContext.activeStroke else { return segment }
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
                    angle: 0
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
        guard let activeStroke = ctx.strokeContext.activeStroke else { return nil }
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
