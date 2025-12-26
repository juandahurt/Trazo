import CoreFoundation
import Tartarus

class FrameScheduler {
    enum Intent {
        case stroke(shape: TextureID)
        case present
        case fill(TextureID, Color)
        case merge(
            layers: [TextureID],
            onlyDirtyIndices: Bool,
            isDrawing: Bool,
            currentLayerIndex: Int
        )
        case tileResolve(onlyDirtyIndices: Bool)
    }
    
    var intentQueue: [Intent] = []
    var accSegments: [StrokeSegment] = []
    var accDirtyTiles: Set<Int> = []
    var ctm: Transform = .identity
    var cpm: Transform = .identity
    let lockQueue = DispatchQueue(label: "")
    
    func enqueue(_ intent: Intent) {
        intentQueue.append(intent)
    }
    
    func buildFrameGraph() -> [RenderPass] {
        var passes: [RenderPass] = []
        for intent in intentQueue {
            switch intent {
            case .present:
                passes.append(PresentPass())
            case .stroke(let shapeTexture):
                passes.append(StrokePass(shapeTextureId: shapeTexture))
                passes.append(ColorizePass(color: .black))
            case .fill(let textureId, let color):
                passes.append(FillPass(color: color, textureId: textureId))
            case .merge(let layers, let onlyDirtyIndices, let isDrawing, let currentLayerIndex):
                passes.append(
                    MergePass(
                        layersTexturesIds: layers,
                        onlyDirtyIndices: onlyDirtyIndices,
                        isDrawing: isDrawing,
                        currentLayerIndex: currentLayerIndex
                    )
                )
            case .tileResolve(let onlyDirtyIndices):
                passes.append(TileResolvePass(onlyDirtyTiles: onlyDirtyIndices))
            }
        }
        return passes
    }
   
    func updateCurrentTransform(_ transform: Transform) {
        lockQueue.async { [weak self] in
            guard let self else { return }
            ctm = transform
        }
    }
    
    func updateCurrentProjection(_ transform: Transform) {
        lockQueue.async { [weak self] in
            guard let self else { return }
            cpm = transform
        }
    }
    
    func ingest(_ contribution: FrameContribution) {
        lockQueue.async { [weak self] in
            guard let self else { return }
            accSegments.append(contentsOf: contribution.segments)
            accDirtyTiles.formUnion(contribution.dirtyTiles)
        }
    }
    
    func drain() -> FrameContext {
        lockQueue.sync {
            defer {
                accSegments = []
                accDirtyTiles = []
                intentQueue = []
            }
            return .init(
                dirtyTiles: accDirtyTiles,
                segments: accSegments,
                ctm: ctm,
                cpm: cpm 
            )
        }
    }
}
