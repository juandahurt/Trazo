import Tartarus

class RenderResources {
    let rows: Int
    let cols: Int
    let canvasSize: Size
    let tileSize: Size
    let intermidiateTexture: TextureID
    let renderableTexture: TextureID
    let grayscaleTexture: TextureID
    let strokeTexture: TextureID
    
    init(
        canvasSize: Size,
        tileSize: Size,
        rows: Int,
        cols: Int
    ) {
        self.canvasSize = canvasSize
        self.tileSize = tileSize
        self.rows = rows
        self.cols = cols
        intermidiateTexture = TextureManager.makeTexture(
            ofSize: canvasSize,
            label: "Intermidiate texture"
        )!
        renderableTexture = TextureManager
            .makeTiledTexture(
                named: "Renderable texture",
                rows: rows,
                columns: cols,
                tileSize: tileSize,
                canvasSize: canvasSize
            )
        grayscaleTexture = TextureManager
            .makeTiledTexture(
                named: "Grayscale texture",
                rows: rows,
                columns: cols,
                tileSize: tileSize,
                canvasSize: canvasSize
            )
        strokeTexture = TextureManager
            .makeTiledTexture(
                named: "Stroke texture",
                rows: rows,
                columns: cols,
                tileSize: tileSize,
                canvasSize: canvasSize
            )
    }
}
