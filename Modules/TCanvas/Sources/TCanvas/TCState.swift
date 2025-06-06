import simd
import UIKit

struct TCState {
    private(set) var layers: [TCLayer]  = []
    var renderableTexture               = -1
    var projectionMatrix                = matrix_identity_float4x4
    var ctm                             = matrix_identity_float4x4
    var currentGesture: TCGestureType   = .none
    
    mutating func addLayer(_ layer: TCLayer) {
        layers.append(layer)
    }
}

struct TCLayer {
    var textureId: Int
    var name: String
}

enum TCGestureType {
    case none, drawWithFinger, transform
}

struct TCTouch {
    let id: Int
    let location: simd_float2
    let phase: UITouch.Phase
}
