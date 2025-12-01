/// A rectangle.
public struct Rect {
    public var x: Float
    public var y: Float
    public var width: Float
    public var height: Float
    
    public init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public extension Rect {
    nonisolated(unsafe)
    static let zero = Rect(x: 0, y: 0, width: 0, height: 0)
}

public extension Rect {
    func intersects(with other: Rect) -> Bool {
        x <= other.x + other.width &&
        x + width >= other.x &&
        y - height <= other.y &&
        y >= other.y - other.height
    }
}
