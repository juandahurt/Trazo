import simd

public struct Point {
    public var x: Float {
        get {
            _value.x
        }
        set {
            _value.x = newValue
        }
    }
    public var y: Float {
        get {
            _value.y
        }
        set {
            _value.y = newValue
        }
    }
   
    var _value: simd_float2
    
    public init(x: Float, y: Float) {
        _value = [x, y]
    }
}

// MARK: - Operators
public extension Point {
    static func +(lhs: Point, rhs: Point) -> Point {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: Point, rhs: Point) -> Point {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func /(lhs: Point, value: Float) -> Point {
        .init(x: lhs.x / value, y: lhs.y / value)
    }
    
    static func *(lhs: Point, value: Float) -> Point {
        .init(x: lhs.x * value, y: lhs.y * value)
    }
    
    static func *(value: Float, point: Point) -> Point {
        point * value
    }
    
    func length() -> Float {
        simd.length(_value)
    }
}

// MARK: - Transformations
public extension Point {
    func applying(_ transform: Transform) -> Point {
        let transformedPoint = transform.matrix * [x, y, 0 ,1]
        return .init(x: transformedPoint.x, y: transformedPoint.y)
    }
}
