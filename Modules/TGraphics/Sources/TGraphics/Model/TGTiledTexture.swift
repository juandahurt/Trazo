public struct TGTiledTexture {
    public let name: String
    public var tiles: [TGTile] = []
    
    public init(name: String) {
        self.name = name
    }
}
