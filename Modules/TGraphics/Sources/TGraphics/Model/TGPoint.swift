public struct TGPoint: Sendable {
    public var x: Float
    public var y: Float
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public extension TGPoint {
    static let zero = Self(x: 0, y: 0)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
}
