class AnimationSystem: System {
    func update(dt: Float, ctx: Context) {
        ctx.liveAnimations.forEach { $0.update(dt: dt, ctx: ctx) }
    }
}
