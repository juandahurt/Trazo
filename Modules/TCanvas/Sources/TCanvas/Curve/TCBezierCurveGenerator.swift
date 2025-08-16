import TTypes
import TGraphics
import simd

class TCBezierCurveGenerator {
    func initialCurve(p0: simd_float2, p1: simd_float2, p2: simd_float2, p3: simd_float2) -> TCBezierCurve {
        let (c1, c2) = findControlPoints(p0: p0, p1: p1, p2: p2, p3: p3)
        
        return .init(
            p0: p0,
            p1: c1,
            p2: c2,
            p3: p3
        )
    }
    
    func middleCurve(p0: simd_float2, p1: simd_float2, p2: simd_float2, p3: simd_float2) -> TCBezierCurve {
        let (c1, c2) = findControlPoints(p0: p0, p1: p1, p2: p2, p3: p3)
        
        return .init(
            p0: p1,
            p1: c1,
            p2: c2,
            p3: p2
        )
    }
    
    func finalCurve(p0: simd_float2, p1: simd_float2, p2: simd_float2, p3: simd_float2) -> TCBezierCurve {
        let (c1, c2) = findControlPoints(p0: p0, p1: p1, p2: p2, p3: p3)
        
        return .init(
            p0: p1,
            p1: c1,
            p2: c2,
            p3: p2
        )
    }
    
    private func findControlPoints(
        p0: simd_float2,
        p1: simd_float2,
        p2: simd_float2,
        p3: simd_float2
    ) -> (c1: simd_float2, c2: simd_float2) {
        let c1 = ((p2 - p0) /** brush.stabilization*/ / 6) + p1
        let c2 = p2 - ((p3 - p1) /** brush.stabilization*/ / 6)
        return (c1, c2)
    }
}
