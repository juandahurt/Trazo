import simd
import TGraphics
import TTypes

public struct TPainter {
    public internal(set) var stroke: [TTTouch] = []
    var touchCount = 0
    var brush = TPBrush.normal
    
    public init() {}
   
    public var brushSize: Float {
        get {
            brush.size
        }
        set {
            brush.size = newValue
        }
    }
    
    public var brushOpacity: Float {
        get {
            brush.opacity
        }
        set {
            brush.opacity = newValue
        }
    }
    
    public mutating func endStroke() {
        stroke = []
        touchCount = 0
    }
    
    public mutating func generatePoints(forTouch touch: TTTouch) -> [TGRenderablePoint] {
        stroke.append(touch)
        touchCount += 1
        
        guard touchCount >= 4 else {
            return [touch].map {
                .init(
                    location: $0.location,
                    size: brushSize
                )
            }
        }
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
        
        let length = distance(p0, p1) + distance(p1, p2) + distance(p2, p3)
        let density: Float = 1
        let n = Int(length * density)
        
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
            points.append(.init(location: location, size: brushSize))
        }
        return points
    }
    
    func findControlPoints(
        p0: simd_float2,
        p1: simd_float2,
        p2: simd_float2,
        p3: simd_float2
    ) -> (c1: simd_float2, c2: simd_float2) {
        let c1 = ((p2 - p0) * brush.stabilization / 6) + p1
        let c2 = p2 - ((p3 - p1) * brush.stabilization / 6)
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
