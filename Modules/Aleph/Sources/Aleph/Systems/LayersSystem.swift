class LayersSystem {
    func update(ctx: inout SceneContext, intent: Intent.Layer) {
        switch intent {
        case .merge:
            ctx.dirtyContext.dirtyIndices = .init((0..<(ctx.renderContext.cols * ctx.renderContext.rows)).map { $0 })
            ctx.renderContext.operations.append(.merge(isDrawing: false))
        case .fill(let color, let index):
            let texture = ctx.layersContext.layers[index].texture
            ctx.renderContext.operations.append(.fill(color: color, texture: texture))
        }
    }
}
