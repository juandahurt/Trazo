import simd

struct TCState {
    private(set) var layers: [TCLayer]  = []
    var renderableTexture               = -1
    var projectionMatrix                = matrix_identity_float4x4
    var ctm                             = matrix_identity_float4x4
    
    mutating func addLayer(_ layer: TCLayer) {
        layers.append(layer)
    }
}

struct TCLayer {
    var textureId: Int
    var name: String
}
