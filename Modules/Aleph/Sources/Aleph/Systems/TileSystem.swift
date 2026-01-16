import Tartarus

class TileSystem {
    func update(ctx: inout SceneContext) {
        let segments = ctx.strokeContext.segments
        let rows = ctx.renderContext.rows
        let cols = ctx.renderContext.cols
        let tileSize = ctx.renderContext.tileSize
        var res = Set<Int>()
        for segment in segments {
            guard !segment.points.isEmpty else { continue }
            let bounds = segment.bounds
            let minX = bounds.x
            let minY = bounds.y
            let maxX = bounds.x + bounds.width
            let maxY = bounds.y + bounds.height
            
            let minCol = Int(minX / tileSize.width)
            let maxCol = Int(maxX / tileSize.width)
            
            let minRow = Int(minY / tileSize.height)
            let maxRow = Int(maxY / tileSize.height)
            
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
            // TODO: append draw operation
        }
        ctx.strokeContext.segments = [] // clean segments
        ctx.dirtyContext.dirtyIndices = res
        ctx.renderContext.operations.append(.merge)
    }
    
    private func index(row: Int, col: Int, cols: Int, rows: Int) -> Int? {
        guard row >= 0, row < rows else { return nil }
        let index = row * cols + col
        return index
    }
}
