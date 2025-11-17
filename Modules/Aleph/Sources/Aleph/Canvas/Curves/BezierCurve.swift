import Foundation
import Tartarus

struct BezierCurve {
    var c0, c1, c2, c3: Point
    
    init(p0: Point, p1: Point, p2: Point, p3: Point) {
        c0 = p0
        c1 = ((p2 - p0) /** brush.stabilization*/ / 6) + p1
        c2 = p2 - ((p3 - p1) /** brush.stabilization*/ / 6)
        c3 = p3
    }
    
    func point(at t: Float) -> Point {
        ((pow(1 - t, 3)) * c0) + (3 * pow(1 - t, 2) * t * c1) + (3 * (1 - t) * pow(t, 2) * c2) + (pow(t, 3) * c3)
    }
}
