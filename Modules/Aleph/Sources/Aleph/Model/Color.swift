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
}

extension Color {
    static let white = Color([1, 1, 1, 1])
}
