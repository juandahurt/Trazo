import simd
import UIKit
import TGraphics

struct TCState {
    private(set) var layers: [TCLayer]  = []
    var renderableTexture               = -1
    var grayscaleTexture: TGTiledTexture?
    var strokeTexture                   = -1
    var projectionMatrix                = matrix_identity_float4x4
    var ctm                             = matrix_identity_float4x4
    var clearColor: simd_float4         = [0.15, 0.15, 0.15, 1]
    var currentLayerIndex               = -1
    
    var isTransformEnabled              = true
    
    var brush                           = TCBrush.nervous
    
    var canvasSize                      = simd_long2.zero
    var tileSize                        = simd_float2.zero
    
    mutating func addLayer(_ layer: TCLayer) {
        layers.append(layer)
    }
}

struct TCLayer {
//    var textureId: Int
    var tiles: [TCTile] = []
    var name: String
}

struct TCTile {
    let position: simd_float2
    let textureId: Int
}


struct TCTiledTexture {
    var name: String
    var tiles: [TCTile] = []
}
