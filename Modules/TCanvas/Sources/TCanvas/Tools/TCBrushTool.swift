import Foundation
import TTypes
import TGraphics
import simd

class TCBrushTool: TCTool {
    var touches: [TCTouch] = []
    var drawableStroke: TCDrawableStroke = .init(segments: [])
    var touchCount = 0
    
    var estimatedTouches: [NSNumber: Int] = [:]
    var receivedEndOfPencilGesture = false
    
    weak var canvasPresenter: TCCanvasPresenter?
    
    final func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        appendTouch(touch)
        let segments = generateSegments(
            forTouchAtIndex: touchCount - 1,
            ctm: ctm,
            brush: brush
        )
        drawableStroke.append(segments)
        onFingerTouchHandleFinish(segments: segments)
    }
    
    func onFingerTouchHandleFinish(segments: [TCDrawableSegment]) {
        fatalError("not implemented")
    }
    
    final func handlePencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        appendTouch(touch)
        if let estimationUpdateIndex = touch.estimationUpdateIndex {
            estimatedTouches[estimationUpdateIndex] = touchCount - 1
        }
        receivedEndOfPencilGesture = touch.phase == .ended || touch.phase == .cancelled
        let segments = generateSegments(
            forTouchAtIndex: touchCount - 1,
            ctm: ctm,
            brush: brush
        )
        drawableStroke.append(segments)
        onPencilTouchHandleFinish(segments: segments)
    }
    
    func onPencilTouchHandleFinish(segments: [TCDrawableSegment]) {
        fatalError("not implemented")
    }
    
    final func handleUpdatedPencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        guard let estimationUpdateIndex = touch.estimationUpdateIndex else { return }
        guard let touchIndex = estimatedTouches[estimationUpdateIndex] else { return }
        estimatedTouches.removeValue(forKey: estimationUpdateIndex)
        
        touches[touchIndex] = touch
        // in this case, we will draw all the stroke not just the segment
        
        if touchIndex <= 2 && !drawableStroke.segments.isEmpty {
            let segment = generateFirstSegment(ctm: ctm, brush: brush)
            drawableStroke.updateSegment(atIndex: 0, segment)
            print("updated first")
        }
        
        
        
//        if touchIndex > 2 && touchIndex < touchCount - 2 && drawableStroke.segments.count > touchIndex && touch.phase == .moved {
//            // update right segment
//            let segment = generateMidSegment(
//                ctm: ctm,
//                brush: brush,
//                touchIndex: touchIndex
//            )
//            drawableStroke.updateSegment(atIndex: touchIndex, segment)
//            
//            // update left segment
//            if touchIndex - 1 > 0 {
//                
//            }
//        }
        
        // update left segment
//        if touchIndex > 0 && !drawableStroke.segments.isEmpty {
//            let segments = generateSegments(forTouchAtIndex: touchIndex, ctm: ctm, brush: brush)
//            if let segment = segments.first {
//                drawableStroke.updateSegment(atIndex: touchIndex - 1, segment)
//            }
//        }
//        
//        if touchIndex < touchCount - 1 && touchIndex < drawableStroke.segments.count {
//            let segments = generateSegments(forTouchAtIndex: touchIndex + 1, ctm: ctm, brush: brush)
//            if let segment = segments.last {
//                drawableStroke.updateSegment(atIndex: touchIndex, segment)
//            }
//        }
        
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
        touchCount += 1
    }
    
    func endStroke() {
        drawableStroke.clear()
        touches = []
        touchCount = 0
        receivedEndOfPencilGesture = false
    }
    
    func generateSegments(forTouchAtIndex index: Int, ctm: TTTransform, brush: TCBrush) -> [TCDrawableSegment] {
        let touch = touches[index] // validate index ?
        var segments: [TCDrawableSegment] = []
        
        switch touch.phase {
        case .moved:
            guard touchCount >= 3 else { return [] }
            if touchCount == 3 {
                let segment = generateFirstSegment(ctm: ctm, brush: brush)
                segments.append(segment)
            } else {
                let segment = generateMidSegment(
                    ctm: ctm,
                    brush: brush,
                    touchIndex: touchCount - 3
                )
                segments.append(segment)
            }
        case .ended, .cancelled: break
//            guard touchCount > 3 else { return [] }
            // add the second-last curve
//            var (points, pointsCount) = findPointsForMidSegment(ctm: ctm, brush: brush)
//            var segment = TCDrawableSegment(points: points, pointsCount: pointsCount)
//            segments.append(segment)
//            // add the last curve
//            (points, pointsCount) = findPointsForFinalSegment(ctm: ctm, brush: brush)
//            segment = TCDrawableSegment(points: points, pointsCount: pointsCount)
//            segments.append(segment)
        default: return []
        }
        
        return segments
    }
    
    func generateFirstSegment(ctm: TTTransform, brush: TCBrush) -> TCDrawableSegment {
        let (points, pointsCount) = findPointsForFirstSegment(ctm: ctm, brush: brush)
        return TCDrawableSegment(points: points, pointsCount: pointsCount)
    }
    
    func generateMidSegment(ctm: TTTransform, brush: TCBrush, touchIndex: Int) -> TCDrawableSegment {
        let (points, pointsCount) = findPointsForMidSegment(
            ctm: ctm,
            brush: brush,
            index: touchIndex
        )
        return TCDrawableSegment(points: points, pointsCount: pointsCount)
    }
    
    func findPointsForFirstSegment(
        ctm: TTTransform,
        brush: TCBrush
    ) -> ([TGRenderablePoint], Int) {
        let index = 0
        let (c1, c2) = findControlPoints(
            p0: touches[0].location,
            p1: touches[0].location,
            p2: touches[1].location,
            p3: touches[2].location
        )
        let p0 = touches[index].location
        let p1 = c1
        let p2 = c2
        let p3 = touches[1].location
        return findPointsForSegment(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            ctm: ctm,
            brush: brush,
            forceRange: (touches[index].force, touches[1].force)
        )
    }
    
    func findPointsForFinalSegment(
        ctm: TTTransform,
        brush: TCBrush
    ) -> ([TGRenderablePoint], Int) {
        let index = touchCount - 1
        let (c1, c2) = findControlPoints(
            p0: touches[index-1].location,
            p1: touches[index].location,
            p2: touches[index].location,
            p3: touches[index].location
        )
        let p0 = touches[index-1].location
        let p1 = c1
        let p2 = c2
        let p3 = touches[index].location
        return findPointsForSegment(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            ctm: ctm,
            brush: brush,
            forceRange: (touches[index-1].force, touches[index].force)
        )
    }
    
    func findPointsForMidSegment(
        ctm: TTTransform,
        brush: TCBrush,
        index: Int
    ) -> ([TGRenderablePoint], Int) {
        let (c1, c2) = findControlPoints(
            p0: touches[index-1].location,
            p1: touches[index].location,
            p2: touches[index+1].location,
            p3: touches[index+2].location
        )
        let p0 = touches[index].location
        let p1 = c1
        let p2 = c2
        let p3 = touches[index+1].location
        
        return findPointsForSegment(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            ctm: ctm,
            brush: brush,
            forceRange: (touches[index].force, touches[index + 1].force)
        )
    }
    
    func findPointsForSegment(
        p0: simd_float2,
        p1: simd_float2,
        p2: simd_float2,
        p3: simd_float2,
        ctm: TTTransform,
        brush: TCBrush,
        forceRange: (f0: Float, f1: Float)
    ) -> ([TGRenderablePoint], Int) {
        // find the distance given the current current transform
        let length = distance(
            p0.applying(ctm.inverse),
            p1.applying(ctm.inverse)
        ) +
        distance(
            p1.applying(ctm.inverse),
            p2.applying(ctm.inverse)
        ) +
        distance(
            p2.applying(ctm.inverse),
            p3.applying(ctm.inverse)
        )
        let density: Float = 1
        let n = max(1, Int(length * density))
        
        var points: [TGRenderablePoint] = []
        for index in 0..<n {
            let t = Float(index) / Float(n)
            var location = cubicBezierValue(
                p0: p0,
                p1: p1,
                p2: p2,
                p3: p3,
                t: t
            )
            if brush.jitter > 0 {
                location.x += Float.random(in: -brush.jitter..<brush.jitter)
                location.y += Float.random(in: -brush.jitter..<brush.jitter)
            }
            points
                .append(
                    .init(
                        location: location,
                        size: brush.size * (
                                forceRange.f0 + t * (forceRange.f1 - forceRange.f0)
                            )
                        // TODO: implement the use of a function for the size
                    )
                )
        }
        
        return (points, n)
    }
    
    func findControlPoints(
        p0: simd_float2,
        p1: simd_float2,
        p2: simd_float2,
        p3: simd_float2
    ) -> (c1: simd_float2, c2: simd_float2) {
        let c1 = ((p2 - p0) /** brush.stabilization*/ / 6) + p1
        let c2 = p2 - ((p3 - p1) /** brush.stabilization*/ / 6)
        return (c1, c2)
    }
    
    func cubicBezierValue(
        p0: simd_float2,
        p1: simd_float2,
        p2: simd_float2,
        p3: simd_float2,
        t: Float
    ) -> simd_float2 {
        ((pow(1 - t, 3)) * p0) + (3 * pow(1 - t, 2) * t * p1) + (3 * (1 - t) * pow(t, 2) * p2) + (pow(t, 3) * p3)
    }
}

