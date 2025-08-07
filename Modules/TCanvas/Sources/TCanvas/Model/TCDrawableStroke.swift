import TGraphics

struct TCDrawableStroke {
    private(set) var segments: [TCDrawableSegment]
    private(set) var pointsCount = 0
    private(set) var segmentCount = 0
    
    mutating func append(_ segments: [TCDrawableSegment]) {
        self.segments.append(contentsOf: segments)
        pointsCount += segments.reduce(into: 0, { $0 += $1.pointsCount })
        segmentCount += 1
    }
    
    mutating func clear() {
        segments = []
        pointsCount = 0
        segmentCount = 0
    }
    
    mutating func updateSegment(atIndex index: Int, _ segment: TCDrawableSegment) {
        segments[index] = segment
    }
}

struct TCDrawableSegment {
    var points: [TGRenderablePoint]
    var pointsCount: Int
}
