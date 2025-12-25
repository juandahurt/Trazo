import Tartarus

fileprivate struct TileGrid {
    let rows: Int
    let cols: Int
    let tileSize: Size
    let canvasSize: Size
}

class TileSystem {
    func invalidate(with segments: [StrokeSegment], boundingBoxes: [Rect]) -> Set<Int> {
        var res = Set<Int>()
        for segment in segments {
            for boxIndex in boundingBoxes.indices {
                if boundingBoxes[boxIndex].intersects(with: segment.bounds) &&
                    !segment.points.isEmpty {
                    res.insert(boxIndex)
                }
            }
        }
        return res
    }
}
