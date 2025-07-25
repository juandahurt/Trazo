import simd
import UIKit

struct TCState {
    private(set) var layers: [TCLayer]  = []
    var renderableTexture               = -1
    var grayscaleTexture                = -1
    var strokeTexture                   = -1
    var projectionMatrix                = matrix_identity_float4x4
    var ctm                             = matrix_identity_float4x4
    var clearColor: simd_float4         = [0.15, 0.15, 0.15, 1]
    var currentLayerIndex               = -1
    
    var isTransformEnabled              = true
    
    var brush                           = TCBrush.nervous
    
    mutating func addLayer(_ layer: TCLayer) {
        layers.append(layer)
    }
}

struct TCLayer {
    var textureId: Int
    var name: String
}
