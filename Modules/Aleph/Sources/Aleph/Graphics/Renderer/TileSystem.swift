import Tartarus

fileprivate struct TileGrid {
    let rows: Int
    let cols: Int
    let tileSize: Size
    let canvasSize: Size
}

class TileSystem {
    func invalidate(with segments: [StrokeSegment]) -> Set<Int> {
        [0]
    }
}
