import TPainter

public struct TCConfig {
    let isTransformEnabled: Bool
    let brush: TPBrush
    
    public init(isTransformEnabled: Bool, brush: TPBrush) {
        self.isTransformEnabled = isTransformEnabled
        self.brush = brush
    }
}
