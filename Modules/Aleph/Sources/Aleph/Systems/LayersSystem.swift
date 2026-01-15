class LayersSystem {
    func update(ctx: inout SceneContext, intent: Intent.Layer) {
        switch intent {
        case .merge(let mergeIntent):
            ctx.renderContext.operations.append(.merge)
        case .fill(let color, let index):
            let texture = ctx.layersContext.layers[index].texture
            ctx.renderContext.operations.append(.fill(color: color, texture: texture))
        }
    }
}
