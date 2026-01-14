struct Layer {
    var name: String
    var texture: TextureID
    
    init(named name: String, texture: TextureID) {
        self.name = name
        self.texture = texture
    }
}
