import simd
import UIKit
import TGraphics

struct TCState {
    private(set) var layers: [TCLayer]  = []
    var renderableTexture: TGTiledTexture?
    var grayscaleTexture: TGTiledTexture?
    var strokeTexture: TGTiledTexture?
    var projectionMatrix                = matrix_identity_float4x4
    var ctm                             = matrix_identity_float4x4
    var clearColor: simd_float4         = [0.15, 0.15, 0.15, 1]
    var currentLayerIndex               = -1
    
    var isTransformEnabled              = true
    
    var brush                           = TCBrush.nervous
    
    var canvasSize                      = simd_long2.zero
    let tilesPerRow                     = 8
    let tilesPerColumn                  = 8
    var tileSize                        = simd_float2.zero
    var dirtyTilesInSegment             = Set<Int>()
    var dirtyTilesInStroke              = Set<Int>()
    
    mutating func addLayer(_ layer: TCLayer) {
        layers.append(layer)
    }
}

struct TCLayer {
    var texture: TGTiledTexture
    var name: String
}
