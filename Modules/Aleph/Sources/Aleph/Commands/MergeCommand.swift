import Tartarus

class MergeCommand: Commandable {
    let dirtyArea: Rect
    
    init(dirtyArea: Rect) {
        self.dirtyArea = dirtyArea
    }
    
    func execute(context: Context) {
        context.pendingPasses.append(MergePass(dirtyArea: dirtyArea, isDrawing: false))
    }
}
