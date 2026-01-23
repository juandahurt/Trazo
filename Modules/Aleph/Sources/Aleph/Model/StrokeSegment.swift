import Tartarus

struct StrokeSegment {
    var bounds: Rect = .zero
    var points: [DrawablePoint] = []
    
    mutating func add(point: DrawablePoint, transform: Float4x4) {
        // we need to take into account the current transformation
        let pos = Point(x: point.position.x, y: point.position.y).applying(
            transform.inverse
        )
        let size = point.size * transform.scale
        defer { points.append(point) }
        guard !points.isEmpty else {
            bounds.x = pos.x
            bounds.y = pos.y
            bounds.width = size / 2
            bounds.height = size / 2
            return
        }
        
        let minX = min(pos.x - size / 2, bounds.x)
        let maxX = max(pos.x + size / 2, bounds.x + bounds.width)
        let minY = min(pos.y - size / 2, bounds.y)
        let maxY = max(pos.y + size / 2, bounds.y + bounds.height)
        
        bounds.x = minX
        bounds.y = minY
        bounds.width = maxX - minX
        bounds.height = maxY - minY
    }
}
