public struct Size {
    public var width: Float
    public var height: Float
    
    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}

public extension Size {
    nonisolated(unsafe)
    static let zero: Size = .init(width: 0, height: 0)
}
