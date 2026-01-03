import Tartarus

struct StrokeSegment {
    var bounds: Rect = .zero
    var points: [DrawablePoint] = []
    
    mutating func add(point: DrawablePoint, ctm: Transform) {
        // we need to take into account the current transformation
        let pos = Point(x: point.position.x, y: point.position.y).applying(ctm.inverse)
        print(pos)
        defer { points.append(point) }
        guard !points.isEmpty else {
            bounds.x = pos.x
            bounds.y = pos.y
            bounds.width = point.size / 2
            bounds.height = point.size / 2
            return
        }
        
        let minX = min(pos.x - point.size / 2, bounds.x)
        let maxX = max(pos.x + point.size / 2, bounds.x + bounds.width)
        let minY = min(pos.y - point.size / 2, bounds.y)
        let maxY = max(pos.y + point.size / 2, bounds.y + bounds.height)
        
        bounds.x = minX
        bounds.y = minY
        bounds.width = maxX - minX
        bounds.height = maxY - minY
    }
}
