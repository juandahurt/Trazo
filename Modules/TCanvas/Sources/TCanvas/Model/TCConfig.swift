public struct TCConfig {
    let isTransformEnabled: Bool
    let brush: TCBrush
    
    public init(isTransformEnabled: Bool, brush: TCBrush) {
        self.isTransformEnabled = isTransformEnabled
        self.brush = brush
    }
}
