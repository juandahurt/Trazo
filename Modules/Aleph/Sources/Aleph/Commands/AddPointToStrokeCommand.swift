class AddPointToStrokeCommand: Command {
    let touch: Touch
    
    init(touch: Touch) {
        self.touch = touch
    }
    
    func execute(context: Context) {
        context.activeStroke?.touches.append(touch)
        // TODO: remove mock pass
        context.pendingPasses.append(
            StrokePass(
                segments: [.init(
                    points: [.init(
                        position: [touch.location.x, touch.location.y],
                        size: 10,
                        opacity: 1,
                        angle: 0
                    )]
                )]
            )
        )
    }
}
