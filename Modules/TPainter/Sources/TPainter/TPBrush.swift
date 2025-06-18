public struct TPBrush: Sendable {
    public var size: Float = 8
    public var opacity: Float = 1
    let jitter: Float
    let stabilization: Float
    // TODO: add more configs
}

public extension TPBrush {
    static let normal = TPBrush(jitter: 0, stabilization: 1)
    static let nervous = TPBrush(jitter: 4, stabilization: 0.3)
}
