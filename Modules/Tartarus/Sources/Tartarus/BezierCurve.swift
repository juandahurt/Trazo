import Foundation

public struct BezierCurve {
    public var c0, c1, c2, c3: Point
    
    private var lookupTable: [Float] = []
   
    public var totalDistance: Float {
        lookupTable.last ?? 0
    }
    
    public init(p0: Point, p1: Point, p2: Point, p3: Point) {
        c0 = p1
        c1 = ((p2 - p0) /** brush.stabilization*/ / 6) + p1
        c2 = p2 - ((p3 - p1) /** brush.stabilization*/ / 6)
        c3 = p2
        
        buildTable()
    }
   
    private mutating func buildTable() {
        let samples = 10
        var lastT: Float = 0.0
        var accDist: Float = 0
        for i in 0...samples {
            let t = Float(i) / Float(samples)
            let lastPoint = point(at: lastT)
            let point = point(at: t)
            let dist = lastPoint.dist(to: point)
            accDist += dist
            lookupTable.append(accDist)
            lastT = t
        }
    }
    
    public func t(atDistance dist: Float) -> Float {
        assert(dist >= 0)
        assert(dist <= totalDistance)
        
        var mid = lookupTable.count / 2
        var left = mid - 1
        var right = mid + 1
        
        while true {
            let value = lookupTable[mid]
            if value == dist { return value }
            
            let leftValue = lookupTable[left]
            let rightValue = lookupTable[right]
            
            if dist < value {
                if dist >= leftValue {
                    let alpha = (dist - leftValue) / (value - leftValue)
                    let tLeft = 0.1 * Float(left)
                    let tRight = 0.1 * Float(mid)
                    return lerp(t: alpha, v0: tLeft, v1: tRight)
                } else {
                    // we move one step to the left
                    left = max(0, left - 1)
                    mid = mid - 1
                    right = max(0, right - 1)
                }
            }
            
            if dist > value {
                if dist <= rightValue {
                    let alpha = (dist - value) / (rightValue - value)
                    let tLeft = 0.1 * Float(mid)
                    let tRight = 0.1 * Float(right)
                    return lerp(t: alpha, v0: tLeft, v1: tRight)
                } else {
                    // we move one step to the right
                    left = max(0, left + 1)
                    mid = mid + 1
                    right = max(0, right + 1)
                }
            }
        }
    }
    
    public func point(at t: Float) -> Point {
        ((pow(1 - t, 3)) * c0) +
        (3 * pow(1 - t, 2) * t * c1) +
        (3 * (1 - t) * pow(t, 2) * c2) +
        (pow(t, 3) * c3)
    }
    
    public func derivative(at t: Float) -> Point {
        3 * (1 - pow(t, 2)) * (c1 - c0) +
        6 * (1 - t) * t * (c2 - c1) +
        3 * pow(t, 2) * (c3 - c2)
    }
    
    public func speed(at t: Float) -> Float {
        derivative(at: t).length()
    }
    
    /// Arc-length from `t0` to `t1` using the Simpson method
    /// - Parameters:
    ///   - t0: start
    ///   - t1: end
    public func length(from t0: Float, to t1: Float) -> Float {
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
