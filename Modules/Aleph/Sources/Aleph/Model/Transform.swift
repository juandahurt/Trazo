import Tartarus

struct Transform {
    var anchor:     Point = .init(x: 0, y: 0)
    var dx:         Float = 0
    var dy:         Float = 0
    var scale:      Float = 1
    var rotation:   Float = 0
    
    var matrix: Float4x4 {
        .identity
            .concatenating(.init(translateByX: -anchor.x, y: -anchor.y))
            .concatenating(.init(scaledBy: scale))
            .concatenating(.init(rotatedBy: -rotation))
            .concatenating(.init(translateByX: anchor.x, y: anchor.y))
            .concatenating(.init(translateByX: dx, y: dy))
    }
}
