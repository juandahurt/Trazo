import Tartarus

struct Layer {
    var name: String
    var texture: TextureID
    
    init(named name: String, size: Size) {
        self.name = name
        self.texture = TextureManager.makeTexture(ofSize: size, label: name)!
    }
}
