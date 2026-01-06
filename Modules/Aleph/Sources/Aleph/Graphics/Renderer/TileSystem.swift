import Tartarus

class TileSystem {
    func invalidate(with segments: [StrokeSegment], rows: Int, cols: Int, tileSize: Size, ctm: Transform) -> Set<Int> {
        var res = Set<Int>()
        for segment in segments {
            guard !segment.points.isEmpty else { return [] }
            let bounds = segment.bounds
            let minX = bounds.x
            let minY = bounds.y
            let maxX = bounds.x + bounds.width
            let maxY = bounds.y + bounds.height
            
            let minCol = Int(minX / tileSize.width)
            let maxCol = Int(maxX / tileSize.width)
            
            let minRow = Int(minY / tileSize.height)
            let maxRow = Int(maxY / tileSize.height)
            
            
            // TODO: fix crash when user tries to draw outside the grid
            
            if minCol == maxCol && minRow == maxRow {
                // the segment is contained within one tile
                if let index = index(row: maxRow, col: maxCol, cols: cols, rows: rows) {
                    res.insert(index)
                }
            } else {
                let dirtyRows = maxRow - minRow
                let dirtyCols = maxCol - minCol
                
                for rowOffset in 0...dirtyRows {
                    for colOffset in 0...dirtyCols {
                        if let index = index(
                            row: minRow + rowOffset,
                            col: minCol + colOffset,
                            cols: cols,
                            rows: rows
                        ) {
                            res.insert(index)
                        }
                    }
                }
            }
        }
        return res
    }
    
    func index(row: Int, col: Int, cols: Int, rows: Int) -> Int? {
        guard row >= 0, row < rows else { return nil }
        let index = row * cols + col
        return index
    }
}
