import TGraphics
import TTypes

public struct TPainter {
    public init() {}
    
    public func generateDrawablePoints(
        forTouch touch: TTTouch,
        in stroke: [TTTouch]
    ) -> [TGRenderablePoint] {
        [touch].map {
            .init(
                location: $0.location,
                size: 5
            )
        }
    }
}
