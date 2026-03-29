import Tartarus

class MergeCommand: Commandable {
    let dirtyArea: Rect
    
    init(dirtyArea: Rect) {
        self.dirtyArea = dirtyArea
    }
    
    func execute(context: Context) {
        context.pendingPasses.append(
            MergePass(
                dirtyArea: dirtyArea,
                sourceGrids: context.document.layers.map { $0.tileGrid },
                destinationGrid: context.canvasGrid,
                blitDestination: context.compositeTextureId
            )
        )
    }
}
