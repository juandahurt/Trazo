class RenderSystem: System {
    enum Operation {
        case stroke
    }
    
    func update(dt: Float, ctx: Context) {
        while let operation = ctx.renderContext.operationQueue.popFirst() {
            switch operation {
            case .stroke:
                let segments = ctx.strokeContext.drainSegments()
                if !segments.isEmpty {
                    let dirtyArea = segments.boundsUnion().clip(
                        .init(
                            x: 0,
                            y: 0,
                            width: ctx.canvasSize.width,
                            height: ctx.canvasSize.height
                        )
                    )
                    ctx.pendingPasses.append(StrokePass(segments: segments))
                    var sourceGrids = ctx.document.layers.map { $0.tileGrid }
                    sourceGrids
                        .insert(
                            ctx.strokeGrid,
                            at: ctx.document.currentLayerIndex + 1
                        )
                    ctx.pendingPasses.append(
                        MergePass(
                            dirtyArea: dirtyArea,
                            sourceGrids: sourceGrids,
                            destinationGrid: ctx.canvasGrid,
                            blitDestination: ctx.compositeTextureId,
                            mustClearBackground: true
                        )
                    )
                }
            }
        }
    }
}
