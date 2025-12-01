import Tartarus

struct StrokeSegment {
    var bounds: Rect = .zero
    var points: [DrawablePoint] = []
    
    mutating func add(point: DrawablePoint, ctm: Transform) {
        // we need to take into account the current transformation
        let pos = Point(x: point.position.x, y: point.position.y).applying(ctm.inverse)
        defer { points.append(point) }
        guard !points.isEmpty else {
            bounds.x = pos.x
            bounds.y = pos.y
            return
        }
        
        let minX = min(pos.x, bounds.x)
        let maxX = max(pos.x, bounds.x + bounds.width)
        let minY = min(pos.y, bounds.y - bounds.height)
        let maxY = max(pos.y, bounds.y)
        
        bounds.x = minX
        bounds.y = maxY
        bounds.width = maxX - minX
        bounds.height = maxY - minY
    }
}
