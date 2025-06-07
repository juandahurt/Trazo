struct TPBrush {
    let jitter: Float
    let stabilization: Float
    // TODO: add more configs
}

extension TPBrush {
    static let normal = TPBrush(jitter: 0, stabilization: 1)
    static let nervous = TPBrush(jitter: 4, stabilization: 0.3)
}
