import Foundation
import TTypes
import TGraphics
import simd

class TCBrushTool: TCTool {
    var touches: [TCTouch] = []
    var drawableStroke = TCStroke()
    
    var estimatedTouches: [NSNumber: Int] = [:]
    var receivedEndOfPencilGesture = false
    
    let bezierCurveGenerator = TCBezierCurveGenerator()
    
    weak var canvasPresenter: TCCanvasPresenter?
    
    final func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        appendTouch(touch)
        let segments = generateSegments(
            forTouchAtIndex: touches.count - 1,
            ctm: ctm,
            brush: brush
        )
        drawableStroke.append(segments)
        onFingerTouchHandleFinish(touch: touch, segments: segments)
    }
    
    func onFingerTouchHandleFinish(touch: TCTouch, segments: [TCStrokeSegment]) {
        fatalError("not implemented")
    }
    
    final func handlePencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        appendTouch(touch)
        receivedEndOfPencilGesture = touch.phase == .ended || touch.phase == .cancelled
        let segments = generateSegments(
            forTouchAtIndex: touches.count - 1,
            ctm: ctm,
            brush: brush
        )
        drawableStroke.append(segments)
        onPencilTouchHandleFinish(touch: touch, segments: segments)
        if let estimationUpdateIndex = touch.estimationUpdateIndex {
            let currentTouchIndex = touches.count - 1
            estimatedTouches[estimationUpdateIndex] = currentTouchIndex
        }
    }
    
    func onPencilTouchHandleFinish(touch: TCTouch, segments: [TCStrokeSegment]) {
        fatalError("not implemented")
    }
    
    func shouldUpdateLeftSegment(touchIndex: Int) -> Bool {
        touchIndex > 0 && drawableStroke.segmentCount >= touchIndex
    }
    
    final func handleUpdatedPencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        guard let estimationUpdateIndex = touch.estimationUpdateIndex else { return }
        guard let touchIndex = estimatedTouches[estimationUpdateIndex] else {
            return
        }
        estimatedTouches.removeValue(forKey: estimationUpdateIndex)
        
        touches[touchIndex] = touch
        
        if shouldUpdateLeftSegment(touchIndex: touchIndex) {
            if touchIndex == 1 {
                let segment = generateFirstSegment(ctm: ctm, brush: brush)
                drawableStroke.updateSegment(atIndex: 0, segment)
            } else {
                let segment = generateMidSegment(ctm: ctm, brush: brush, touchIndex: touchIndex - 1)
                drawableStroke.updateSegment(atIndex: touchIndex - 1, segment)
            }
        }
        
        // check if we need to update the last segment
        if touches.last?.phase == .ended || touches.last?.phase == .cancelled {
            if touchIndex == touches.count - 2 {
                let segment = generateFinalSegment(ctm: ctm, brush: brush)
                drawableStroke
                    .updateSegment(atIndex: drawableStroke.segmentCount - 1, segment)
            }
        }
        
        onUpdatedPencilTouchHandleFinish()
        
        if estimatedTouches.isEmpty && receivedEndOfPencilGesture {
            canvasPresenter?.didFinishPencilGesture()
        }
    }
    
    func onUpdatedPencilTouchHandleFinish() {
        fatalError("not implemented")
    }
    
    func appendTouch(_ touch: TCTouch) {
        touches.append(touch)
    }
    
    func endStroke() {
        drawableStroke.clear()
        touches = []
        receivedEndOfPencilGesture = false
    }
    
    func generateSegments(forTouchAtIndex index: Int, ctm: TTTransform, brush: TCBrush) -> [TCStrokeSegment] {
        let touch = touches[index] // validate index ?
        var segments: [TCStrokeSegment] = []
        
        switch touch.phase {
        case .moved:
            guard touches.count >= 3 else { return [] }
            if touches.count == 3 {
                let segment = generateFirstSegment(ctm: ctm, brush: brush)
                segments.append(segment)
            } else {
                let segment = generateMidSegment(
                    ctm: ctm,
                    brush: brush,
                    touchIndex: touches.count - 3
                )
                segments.append(segment)
            }
        case .ended, .cancelled:
            guard touches.count > 3 else { return [] }
            // add the second-last curve
            var segment = generateMidSegment(ctm: ctm, brush: brush, touchIndex: index - 2)
            segments.append(segment)
            // add the last curve
            segment = generateFinalSegment(ctm: ctm, brush: brush)
            segments.append(segment)
        default: return []
        }
        
        return segments
    }
    
    func generateFirstSegment(ctm: TTTransform, brush: TCBrush) -> TCStrokeSegment {
        let points = findPointsForFirstSegment(ctm: ctm, brush: brush)
        return TCStrokeSegment(points: points, pointsCount: points.count)
    }
    
    func generateMidSegment(ctm: TTTransform, brush: TCBrush, touchIndex: Int) -> TCStrokeSegment {
        let points = findPointsForMidSegment(
            ctm: ctm,
            brush: brush,
            index: touchIndex
        )
        return TCStrokeSegment(points: points, pointsCount: points.count)
    }
    
    func generateFinalSegment(ctm: TTTransform, brush: TCBrush) -> TCStrokeSegment {
        let points = findPointsForFinalSegment(
            ctm: ctm,
            brush: brush
        )
        return TCStrokeSegment(points: points, pointsCount: points.count)
    }
    
    func findPointsForFirstSegment(
        ctm: TTTransform,
        brush: TCBrush
    ) -> [TGRenderablePoint] {
        let curve = bezierCurveGenerator.initialCurve(
            p0: touches[0].location,
            p1: touches[0].location,
            p2: touches[1].location,
            p3: touches[2].location
        )
        return findPointsForCurve(
            curve,
            ctm: ctm,
            brush: brush,
            forceRange: (touches[0].force, touches[1].force)
        )
    }
    
    func findPointsForFinalSegment(
        ctm: TTTransform,
        brush: TCBrush
    ) -> [TGRenderablePoint] {
        let index = touches.count - 1
        let curve = bezierCurveGenerator.finalCurve(
            p0: touches[index - 2].location,
            p1: touches[index - 1].location,
            p2: touches[index].location,
            p3: touches[index].location
        )
        return findPointsForCurve(
            curve,
            ctm: ctm,
            brush: brush,
            forceRange: (touches[index - 1].force, touches[index].force)
        )
    }
    
    func findPointsForMidSegment(
        ctm: TTTransform,
        brush: TCBrush,
        index: Int
    ) -> [TGRenderablePoint] {
        let curve = bezierCurveGenerator.middleCurve(
            p0: touches[index - 1].location,
            p1: touches[index].location,
            p2: touches[index + 1].location,
            p3: touches[index + 2].location
        )
        return findPointsForCurve(
            curve,
            ctm: ctm,
            brush: brush,
            forceRange: (touches[index].force, touches[index + 1].force)
        )
    }
    
    func findPointsForCurve(
        _ curve: TCBezierCurve,
        ctm: TTTransform,
        brush: TCBrush,
        forceRange: (f0: Float, f1: Float)
    ) -> [TGRenderablePoint] {
        // find the distance given the current current transform
        let length = distance(
            curve.p0.applying(ctm.inverse),
            curve.p1.applying(ctm.inverse)
        ) +
        distance(
            curve.p1.applying(ctm.inverse),
            curve.p2.applying(ctm.inverse)
        ) +
        distance(
            curve.p2.applying(ctm.inverse),
            curve.p3.applying(ctm.inverse)
        )
        let density: Float = 1
        let n = max(1, Int(length * density))
        
        var points: [TGRenderablePoint] = []
        for index in 0..<n {
            let t = Float(index) / Float(n)
            var location = curve.value(at: t)
            if brush.jitter > 0 {
                location.x += Float.random(in: -brush.jitter..<brush.jitter)
                location.y += Float.random(in: -brush.jitter..<brush.jitter)
            }
            points
                .append(
                    .init(
                        location: location,
                        size: brush.size * (
                            (1 - t) * forceRange.f0 + forceRange.f1 * t
                        )
                        // TODO: implement the use of a function for the size
                    )
                )
        }
        
        return points
    }
}
