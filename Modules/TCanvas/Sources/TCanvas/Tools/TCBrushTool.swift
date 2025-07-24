import Foundation
import TTypes
import TGraphics
import simd

class TCBrushTool: TCTool {
    var touches: [TCTouch] = []
    var drawableStroke: TCDrawableStroke = .init(segments: [])
    var touchCount = 0
    
    var estimatedTouches: [NSNumber: Int] = [:]
    
    weak var canvasPresenter: TCCanvasPresenter?
    
    func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        generateAndDrawSegments(forTouch: touch, ctm: ctm, brush: brush)
    }
    
    func handlePencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        if let estimationUpdateIndex = touch.estimationUpdateIndex {
            estimatedTouches[estimationUpdateIndex] = touchCount
        }
        
//        generatePoints(forTouch: touch, ctm: ctm, brush: brush)
    }
    
    func handleUpdatedPencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        guard let estimationUpdateIndex = touch.estimationUpdateIndex else { return }
        estimatedTouches.removeValue(forKey: estimationUpdateIndex)
        // TODO: update segments
    }
    
    func endStroke() {
        drawableStroke.clear()
        touches = []
        touchCount = 0
    }
    
    func generateAndDrawSegments(forTouch touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        touches.append(touch)
        touchCount += 1
        var generatedSegments: [TCDrawableSegment] = []
        
        switch touch.phase {
        case .moved:
            guard touchCount >= 3 else { return }
            if touchCount == 3 {
                let (points, pointsCount) = findPointsForFirstSegment(ctm: ctm, brush: brush)
                let segment = TCDrawableSegment(points: points, pointsCount: pointsCount)
                drawableStroke.append(segment)
                generatedSegments.append(segment)
            } else {
                let (points, pointsCount) = findPointsForMidSegment(ctm: ctm, brush: brush)
                let segment = TCDrawableSegment(points: points, pointsCount: pointsCount)
                drawableStroke.append(segment)
                generatedSegments.append(segment)
            }
        case .ended, .cancelled:
            guard touchCount > 3 else { return }
            // add the second-last curve
            var (points, pointsCount) = findPointsForMidSegment(ctm: ctm, brush: brush)
            var segment = TCDrawableSegment(points: points, pointsCount: pointsCount)
            drawableStroke.append(segment)
            generatedSegments.append(segment)
            // add the last curve
            (points, pointsCount) = findPointsForFinalSegment(ctm: ctm, brush: brush)
            segment = TCDrawableSegment(points: points, pointsCount: pointsCount)
            drawableStroke.append(segment)
            generatedSegments.append(segment)
        default: return
        }
        
        for segment in generatedSegments {
            canvasPresenter?.draw(segment: segment)
        }
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
            brush: brush
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
            brush: brush
        )
    }
    
    func findPointsForMidSegment(
        ctm: TTTransform,
        brush: TCBrush
    ) -> ([TGRenderablePoint], Int) {
        let index = touchCount - 3
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
            brush: brush
        )
    }
    
    func findPointsForSegment(
        p0: simd_float2,
        p1: simd_float2,
        p2: simd_float2,
        p3: simd_float2,
        ctm: TTTransform,
        brush: TCBrush
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
            points.append(.init(location: location, size: 8)) // TODO: add real size
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

class TCDrawingTool: TCBrushTool {
    override func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        super.handleFingerTouch(touch, ctm: ctm, brush: brush)
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func handlePencilTouch(
        _ touch: TCTouch,
        ctm: TTTransform,
        brush: TCBrush
    ) {
        super.handlePencilTouch(touch, ctm: ctm, brush: brush)
//        canvasPresenter?.draw(segment: drawableStroke.segments.last)
//        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterDrawing()
    }
}

class TCErasingTool: TCBrushTool {
    override func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        super.handleFingerTouch(touch, ctm: ctm, brush: brush)
        if touch.phase == .began {
            canvasPresenter?.copyCurrrentLayerToStrokeTexture()
        }
//        canvasPresenter?.erase(points: points)
//        canvasPresenter?.mergeLayersWhenErasing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterErasing()
    }
}
