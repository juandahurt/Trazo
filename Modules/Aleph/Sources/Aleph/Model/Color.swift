struct Color {
    var r, g, b, a: Float
    
    @inlinable
    init(_ value: [Float]) {
        assert(value.count == 4, "color must have 4 values")
        r = value[0]
        g = value[1]
        b = value[2]
        a = value[3]
    }
    
    func withOpacity(_ a: Float) -> Color {
        .init([r, g, b, a])
    }
}

extension Color {
    static let clear = Color([0, 0, 0, 0])
    static let white = Color([1, 1, 1, 1])
    static let black = Color([0, 0, 0, 1])
    static let blue = Color([0, 0, 1, 1])
}
