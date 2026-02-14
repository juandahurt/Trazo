import Tartarus

struct StrokeSegment {
    var bounds: Rect = .zero
    var points: [DrawablePoint] = []
    let padding: Float = 2.0  // Ajusta este valor según necesites
    
    mutating func add(point: DrawablePoint) {
        // we need to take into account the current transformation
        let pos = Point(x: point.position.x, y: point.position.y)
        let size = point.size
        defer { points.append(point) }
        
        guard !points.isEmpty else {
            bounds.x = pos.x - size / 2 - padding
            bounds.y = pos.y - size / 2 - padding
            bounds.width = size + padding * 2
            bounds.height = size + padding * 2
            return
        }
        
        let minX = min(pos.x - size / 2 - padding, bounds.x)
        let maxX = max(pos.x + size / 2 + padding, bounds.x + bounds.width)
        let minY = min(pos.y - size / 2 - padding, bounds.y)
        let maxY = max(pos.y + size / 2 + padding, bounds.y + bounds.height)
        
        bounds.x = minX
        bounds.y = minY
        bounds.width = maxX - minX
        bounds.height = maxY - minY
    }
}
