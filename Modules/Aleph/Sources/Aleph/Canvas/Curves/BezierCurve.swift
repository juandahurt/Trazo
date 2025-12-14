import Foundation
import Tartarus

struct BezierCurve {
    var c0, c1, c2, c3: Point
    
    init(p0: Point, p1: Point, p2: Point, p3: Point) {
        c0 = p1
        c1 = ((p2 - p0) /** brush.stabilization*/ / 6) + p1
        c2 = p2 - ((p3 - p1) /** brush.stabilization*/ / 6)
        c3 = p2
    }
    
    func point(at t: Float) -> Point {
        ((pow(1 - t, 3)) * c0) +
        (3 * pow(1 - t, 2) * t * c1) +
        (3 * (1 - t) * pow(t, 2) * c2) +
        (pow(t, 3) * c3)
    }
    
    func derivative(at t: Float) -> Point {
        3 * (1 - pow(t, 2)) * (c1 - c0) +
        6 * (1 - t) * t * (c2 - c1) +
        3 * pow(t, 2) * (c3 - c2)
    }
    
    func speed(at t: Float) -> Float {
        derivative(at: t).length()
    }
    
    /// Arc-length from `t0` to `t1` using the Simpson method
    /// - Parameters:
    ///   - t0: start
    ///   - t1: end
    func length(from t0: Float, to t1: Float) -> Float {
        let n = 10 // number of iterations
        assert(n.isMultiple(of: 2)) // te value must be even
        let deltaT = (t1 - t0) / Float(n)
        var sum: Float = 0.0
        
        for i in 0..<n {
            let t = t0 + deltaT * Float(i)
            let c: Float = (i == 0 || i == n) ? 1 : (i % 2 == 0 ? 2 : 4)
            sum += c * speed(at: t)
        }
        
        return (deltaT / 3) * sum
    }
}
