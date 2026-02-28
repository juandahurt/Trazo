public func lerp(t: Float, v0: Float, v1: Float) -> Float {
    (1 - t) * v0 + t * v1
}

public func lerp(t: Double, v0: Double, v1: Double) -> Double {
    (1 - t) * v0 + t * v1
}
