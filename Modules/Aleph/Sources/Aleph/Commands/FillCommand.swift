class FillCommand: Commandable {
    let color: Color
    let layerIndex: Int
    
    init(color: Color, layerIndex: Int) {
        self.color = color
        self.layerIndex = layerIndex
    }
    
    func execute(context: Context) {
        let tileGrid = context.document.layers[layerIndex].tileGrid
        context.pendingPasses.append(FillPass(color: color, tileGrid: tileGrid))
    }
}
