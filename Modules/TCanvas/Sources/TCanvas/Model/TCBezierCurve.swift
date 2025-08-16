import simd

struct TCBezierCurve {
    let p0: simd_float2
    let p1: simd_float2
    let p2: simd_float2
    let p3: simd_float2
    
    func value(at t: Float) -> simd_float2 {
        let t2 = pow(t, 2)
        let oneMinusT = 1 - t
        return ((pow(oneMinusT, 3)) * p0) + (3 * pow(oneMinusT, 2) * t * p1) + (3 * (oneMinusT) * t2 * p2) + (
            pow(t, 3) * p3
        )
    }
}
