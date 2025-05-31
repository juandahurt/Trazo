struct TCState {
    private(set) var layers: [TCLayer] = []
    var renderableTexture = -1
    
    mutating func addLayer(_ layer: TCLayer) {
        layers.append(layer)
    }
}

struct TCLayer {
    var textureId: Int
    var name: String
}
