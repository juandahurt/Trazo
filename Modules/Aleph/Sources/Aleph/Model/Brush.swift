public struct Brush {
    public var shapeTextureID: TextureID
    public var granularityTextureID: TextureID
    public var spacing: Float
    public var pointSize: Float
    public var opacity: Float
    public var blendMode: BlendMode
    
    public init(
        shapeTextureID: TextureID,
        granularityTextureID: TextureID,
        spacing: Float,
        pointSize: Float,
        opacity: Float,
        blendMode: BlendMode
    ) {
        self.shapeTextureID = shapeTextureID
        self.granularityTextureID = granularityTextureID
        self.spacing = spacing
        self.pointSize = pointSize
        self.opacity = opacity
        self.blendMode = blendMode
    }
}
