class TransformCommand: Command {
    let transform: Transform
    
    init(transform: Transform) {
        self.transform = transform
    }
    
    func execute(context: Context) {
        context.cameraTransform.anchor = transform.anchor
        context.cameraTransform.dx += transform.dx
        context.cameraTransform.dy += transform.dy
        context.cameraTransform.scale *= transform.scale
        context.cameraTransform.rotation += transform.rotation
        
        context.cameraMatrix = context.cameraMatrix.concatenating(transform.matrix)
    }
}
