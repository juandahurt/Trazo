import TTypes
import TGraphics
import simd

class TCBrushTool: TCTool {
    var stroke: [TTTouch] = []
    var touchCount = 0
    var points: [TGRenderablePoint] = []
    
    weak var canvasPresenter: TCCanvasPresenter?
    
    func handleTouch(_ touch: TTTouch, ctm: TTTransform, brush: TCBrush) {
        generatePoints(forTouch: touch, ctm: ctm, brush: brush)
    }
    
    func endStroke() {
        stroke = []
        touchCount = 0
        points = []
    }
    
    func generatePoints(forTouch touch: TTTouch, ctm: TTTransform, brush: TCBrush) {
        stroke.append(touch)
        touchCount += 1
        
        switch touch.phase {
        case .moved:
            guard touchCount >= 3 else { return }
            if touchCount == 3 {
                points
                    .append(contentsOf: findPointsForFirstSegment(ctm: ctm, brush: brush))
            } else {
                points.append(contentsOf: findPointsForMidSegment(ctm: ctm, brush: brush))
            }
        case .ended, .cancelled:
            guard touchCount > 3 else { return }
            // add the second-last curve
            points.append(contentsOf: findPointsForMidSegment(ctm: ctm, brush: brush))
            // add the last curve
            points.append(contentsOf: findPointsForFinalSegment(ctm: ctm, brush: brush))
        default: break
        }
    }
    
    func findPointsForFirstSegment(ctm: TTTransform, brush: TCBrush) -> [TGRenderablePoint] {
        let index = 0
        let (c1, c2) = findControlPoints(
            p0: stroke[0].location,
            p1: stroke[0].location,
            p2: stroke[1].location,
            p3: stroke[2].location
        )
        let p0 = stroke[index].location
        let p1 = c1
        let p2 = c2
        let p3 = stroke[1].location
        return findPointsForSegment(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            ctm: ctm,
            brush: brush
        )
    }
    
    func findPointsForFinalSegment(ctm: TTTransform, brush: TCBrush) -> [TGRenderablePoint] {
        let index = touchCount - 1
        let (c1, c2) = findControlPoints(
            p0: stroke[index-1].location,
            p1: stroke[index].location,
            p2: stroke[index].location,
            p3: stroke[index].location
        )
        let p0 = stroke[index-1].location
        let p1 = c1
        let p2 = c2
        let p3 = stroke[index].location
        return findPointsForSegment(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            ctm: ctm,
            brush: brush
        )
    }
    
    func findPointsForMidSegment(ctm: TTTransform, brush: TCBrush) -> [TGRenderablePoint] {
        let index = touchCount - 3
        let (c1, c2) = findControlPoints(
            p0: stroke[index-1].location,
            p1: stroke[index].location,
            p2: stroke[index+1].location,
            p3: stroke[index+2].location
        )
        let p0 = stroke[index].location
        let p1 = c1
        let p2 = c2
        let p3 = stroke[index+1].location
        
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
    ) -> [TGRenderablePoint] {
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
        
        return points
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
    override func handleTouch(_ touch: TTTouch, ctm: TTTransform, brush: TCBrush) {
        super.handleTouch(touch, ctm: ctm, brush: brush)
        canvasPresenter?.draw(points: points)
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterDrawing()
    }
}

class TCErasingTool: TCBrushTool {
    override func handleTouch(_ touch: TTTouch, ctm: TTTransform, brush: TCBrush) {
        super.handleTouch(touch, ctm: ctm, brush: brush)
        if touch.phase == .began {
            canvasPresenter?.copyCurrrentLayerToStrokeTexture()
        }
        canvasPresenter?.erase(points: points)
        canvasPresenter?.mergeLayersWhenErasing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterErasing()
    }
}
