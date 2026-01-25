class Document {
    var layers:             [Layer] = []
    var currentLayerIndex:  Int = -1
    var currentLayer: Layer {
        layers[currentLayerIndex]
    }
    
    init(layers: [Layer], currentLayerIndex: Int) {
        self.layers = layers
        self.currentLayerIndex = currentLayerIndex
    }
}
