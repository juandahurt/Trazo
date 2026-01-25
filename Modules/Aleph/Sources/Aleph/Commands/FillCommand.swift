class FillCommand: Command {
    let color: Color
    let texture: TextureID
    
    init(color: Color, texture: TextureID) {
        self.color = color
        self.texture = texture
    }
    
    func execute(context: Context) {
        context.pendingPasses.append(FillPass(color: color, texture: texture))
    }
}
