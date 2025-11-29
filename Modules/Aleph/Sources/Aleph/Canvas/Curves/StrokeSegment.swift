import Tartarus

struct StrokeSegment {
    var boundingBox: Rect = .zero
    var points: [DrawablePoint] = []
    
    mutating func add(point: DrawablePoint, ctm: Transform) {
        // we need to take into account the current transformation
        let pos = Point(x: point.position.x, y: point.position.y).applying(ctm.inverse)
        defer { points.append(point) }
        guard !points.isEmpty else {
            boundingBox.x = pos.x
            boundingBox.y = pos.y
            return
        }
        
        // finding the box dimensions
        let distX = abs(pos.x - boundingBox.x)
        if distX > boundingBox.width {
            boundingBox.width = distX
        }
        let distY = abs(pos.y - boundingBox.y)
        if distY > boundingBox.height {
            boundingBox.height = distY
        }
        
        // finding the origin of the box
        boundingBox.y = max(boundingBox.y, pos.y)
        boundingBox.x = min(boundingBox.x, pos.x)
    }
}
