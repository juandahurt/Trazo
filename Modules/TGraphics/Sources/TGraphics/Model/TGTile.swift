public struct TGTile {
    public var position: TGPoint = .zero
    public var textureId: Int
    
    public init(position: TGPoint, textureId: Int) {
        self.position = position
        self.textureId = textureId
    }
}
