import CoreFoundation
import Foundation
import Tartarus

class FrameScheduler {
    enum Intent {
        case stroke(
            shape: TextureID,
            layers: [TextureID],
            currentLayerIndex: Int
        )
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
    var needsToPresent = false
    let lockQueue = DispatchQueue(label: "")
    
    func enqueue(_ intent: Intent) {
        lockQueue.async { [weak self] in
            guard let self else { return }
            if intent is StrokePass {
                guard !intentQueue.contains(where: { $0 is StrokePass }) else { return }
            }
            intentQueue.append(intent)
        }
    }
    
    func buildFrameGraph() -> [RenderPass] {
        lockQueue.sync {
            var passes: [RenderPass] = []
            for intent in intentQueue {
                switch intent {
                case .stroke(let shapeTexture, let layers, let currentLayerIndex):
                    passes.append(StrokePass(shapeTextureId: shapeTexture))
                    passes.append(ColorizePass(color: .black))
                    passes.append(
                        MergePass(
                            layersTexturesIds: layers,
                            onlyDirtyIndices: true,
                            isDrawing: true,
                            currentLayerIndex: currentLayerIndex
                        )
                    )
                    passes.append(TileResolvePass(onlyDirtyTiles: true))
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
            if needsToPresent && !passes.isEmpty {
                passes.append(PresentPass())
            }
            return passes
        }
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
