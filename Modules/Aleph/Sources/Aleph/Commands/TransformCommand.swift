class TransformCommand: Command {
    let transform: Transform
    
    init(transform: Transform) {
        self.transform = transform
    }
    
    func execute(context: Context) {
        context.cameraTransform.dx += transform.dx
        context.cameraTransform.dy += transform.dy
    }
}
