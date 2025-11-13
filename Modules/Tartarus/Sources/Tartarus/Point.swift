public struct Point {
    public var x: Float
    public var y: Float
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
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
}

// MARK: - Transformations
public extension Point {
    func applying(_ transform: Transform) -> Point {
        let x = self.x * transform.a + self.y * transform.c + transform.tx
        let y = self.x * transform.b + self.y * transform.d + transform.ty
        return .init(x: x, y: y)
    }
}
