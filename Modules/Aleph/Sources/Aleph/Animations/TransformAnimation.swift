import Tartarus

class TransformAnimation: Animation {
    override func update(dt: Float, ctx: Context) {
        guard let fromValue = fromValue as? Transform else { return }
        guard let toValue = toValue as? Transform else { return }
        
        let t = ease(t: min(1.0, elapsedTime / duration))
        ctx.cameraTransform.dx = lerp(t: t, v0: fromValue.dx, v1: toValue.dx)
        ctx.cameraTransform.dy = lerp(t: t, v0: fromValue.dy, v1: toValue.dy)
        ctx.cameraTransform.scale = lerp(t: t, v0: fromValue.scale, v1: toValue.scale)
        ctx.cameraTransform.rotation = lerp(
            t: t,
            v0: fromValue.rotation,
            v1: toValue.rotation
        )
        ctx.cameraTransform.anchor.x = lerp(
            t: t,
            v0: fromValue.anchor.x,
            v1: toValue.anchor.x
        )
        ctx.cameraTransform.anchor.y = lerp(
            t: t,
            v0: fromValue.anchor.y,
            v1: toValue.anchor.y
        )
        
        elapsedTime += dt
        
        if elapsedTime >= duration {
            ctx.cameraTransform = toValue
        }
        
        ctx.cameraMatrix = ctx.cameraTransform.matrix
    }
}
