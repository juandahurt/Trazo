class TransformSystem: System {
    private var unhandledTransforms: [Transform] = []
    
    func enqueue(_ transform: Transform) {
        unhandledTransforms.append(transform)
    }
    
    func update(dt: Float, ctx: Context) {
        while let transform = unhandledTransforms.popFirst() {
            ctx.cameraTransform.anchor = transform.anchor
            ctx.cameraTransform.dx += transform.dx
            ctx.cameraTransform.dy += transform.dy
            ctx.cameraTransform.scale *= transform.scale
            ctx.cameraTransform.rotation += transform.rotation
            
            ctx.cameraMatrix = ctx.cameraMatrix.concatenating(transform.matrix)
        }
    }
}
