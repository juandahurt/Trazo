class EndStrokeCommand: Command {
    let touch: Touch
    
    init(touch: Touch) {
        self.touch = touch
    }
    
    func execute(context: Context) {
        context.activeStroke?.touches.append(touch)
        print("end touch")
        print(context.activeStroke!.touches.count)
    }
}
