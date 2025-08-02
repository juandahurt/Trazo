import TGraphics

struct TCDrawableStroke {
    private(set) var segments: [TCDrawableSegment]
    private(set) var pointsCount = 0
    
    mutating func append(_ segments: [TCDrawableSegment]) {
        self.segments.append(contentsOf: segments)
        pointsCount += segments.reduce(into: 0, { $0 += $1.pointsCount })
        assert(pointsCount == self.segments.map(\.pointsCount).reduce(into: 0, {$0 += $1}))
    }
    
    mutating func clear() {
        segments = []
        pointsCount = 0
    }
    
    mutating func updateSegment(atIndex index: Int, _ segment: TCDrawableSegment) {
        segments[index] = segment
        assert(segments.map(\.pointsCount).reduce(into: 0, {$0 += $1}) == pointsCount)
    }
}

struct TCDrawableSegment {
    var points: [TGRenderablePoint]
    var pointsCount: Int
}
