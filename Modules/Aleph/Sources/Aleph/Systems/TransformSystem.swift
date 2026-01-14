import Foundation
import Tartarus

class TransformSystem {
    func update(ctx: inout SceneContext, intent: Intent.Transform) {
        let transform = ctx.renderContext.transform
        switch intent {
        case .translation(let x, let y):
            ctx.renderContext.transform = transform
                .concatenating(.init(translateByX: x, y: y))
        case .zoom(anchor: let anchor, scale: let scale):
            let initialScale = transform.scale
            let totalScale = initialScale * scale
            let newScale = totalScale / initialScale
            let scaleTransform = Transform(translateByX: -anchor.x, y: -anchor.y)
                .concatenating(.init(scaledBy: newScale))
                .concatenating(.init(translateByX: anchor.x, y: anchor.y))
            ctx.renderContext.transform = transform.concatenating(scaleTransform)
        }
    }
}

