public struct TCBrush: Sendable {
    public var size: Float = 8
    public var opacity: Float = 1
    let jitter: Float
    let stabilization: Float
    // TODO: add more configs
}

public extension TCBrush {
    static let normal = TCBrush(jitter: 0, stabilization: 1)
    static let nervous = TCBrush(jitter: 4, stabilization: 0.3)
}
