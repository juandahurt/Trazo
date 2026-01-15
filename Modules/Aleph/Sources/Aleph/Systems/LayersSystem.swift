class LayersSystem {
    func update(ctx: inout SceneContext, intent: Intent.Layer) {
        switch intent {
        case .merge(let mergeIntent): break
//            switch mergeIntent {
//            case .all:
//                ctx.
//            case .indices(let set):
//                
//            }
        case .fill(let color, let index):
            let texture = ctx.renderContext.renderableTexture
//            let texture = ctx.layersContext.layers[index].texture
            ctx.renderContext.operations.append(.fill(color: color, texture: texture))
        }
    }
}
