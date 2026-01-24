import Tartarus

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

extension TransformCommand {
    static func translate(dx: Float, dy: Float) -> TransformCommand {
        TransformCommand(transform: .init(dx: dx, dy: dy))
    }
    
    static func pinch(anchor: Point, scale: Float) -> TransformCommand {
        TransformCommand(transform: .init(anchor: anchor, scale: scale))
    }
    
    static func rotate(anchor: Point, angle: Float) -> TransformCommand {
        TransformCommand(transform: .init(anchor: anchor, rotation: angle))
    }
}
