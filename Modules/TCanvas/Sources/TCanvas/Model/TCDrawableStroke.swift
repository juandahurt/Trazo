import TGraphics

struct TCDrawableStroke {
    private(set) var segments: [TCDrawableSegment]
    private(set) var pointsCount = 0
    
    mutating func append(_ segment: TCDrawableSegment) {
        segments.append(segment)
        pointsCount += segment.pointsCount
    }
    
    mutating func clear() {
        segments = []
    }
}

struct TCDrawableSegment {
    var points: [TGRenderablePoint]
    var pointsCount: Int
}
