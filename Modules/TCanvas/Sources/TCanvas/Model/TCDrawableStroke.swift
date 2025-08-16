import TGraphics

struct TCDrawableStroke {
    private var segments: [TCDrawableSegment]
    private(set) var pointsCount = 0
    var segmentCount: Int {
        segments.count
    }
    var points: [TGRenderablePoint] {
        segments.reduce(into: []) { result, segment in
            result.append(contentsOf: segment.points)
        }
    }
    
    public init() {
        segments = []
    }
    
    mutating func append(_ segments: [TCDrawableSegment]) {
        self.segments.append(contentsOf: segments)
        pointsCount += segments.reduce(into: 0, { $0 += $1.pointsCount })
    }
    
    mutating func clear() {
        segments = []
        pointsCount = 0
    }
    
    mutating func updateSegment(atIndex index: Int, _ segment: TCDrawableSegment) {
        segments[index] = segment
    }
}

struct TCDrawableSegment {
    var points: [TGRenderablePoint]
    var pointsCount: Int
}
