import Tartarus

struct Transform {
    var dx:         Float = 0
    var dy:         Float = 0
    var scale:      Float = 0
    var rotation:   Float = 0
    
    var matrix: Float4x4 {
        .init(translateByX: dx, y: dy)
    }
}
