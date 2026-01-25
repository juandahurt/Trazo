class BeginStrokeCommand: Command {
    let touch: Touch
    
    init(touch: Touch) {
        self.touch = touch
    }
    
    func execute(context: Context) {
        context.activeStroke = .init()
        context.activeStroke?.touches.append(touch)
        // TODO: save action in undo manager
    }
}
