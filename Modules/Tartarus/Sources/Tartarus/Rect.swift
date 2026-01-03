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
        y + height >= other.y &&
        y <= other.y + other.height
    }
    
    func applying(_ transform: Transform) -> Rect {
        let p1 = Point(x: x, y: y).applying(transform)
        let p2 = Point(x: x  + width, y: y).applying(transform)
        let p3 = Point(x: x, y: y - height).applying(transform)
        let p4 = Point(x: x + width, y: y + height).applying(transform)
        
        let minX = min(p1.x, p2.x, p3.x, p4.x)
        let maxX = max(p1.x, p2.x, p3.x, p4.x)
        let minY = min(p1.y, p2.y, p3.y, p4.y)
        let maxY = max(p1.y, p2.y, p3.y, p4.y)
        
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
