import CoreFoundation
import Tartarus

class FrameScheduler {
    enum Intent {
        case stroke
        case present
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
        intentQueue.map {
            switch $0 {
            case .present:
                PresentPass()
            case .stroke:
                StrokePass()
            }
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
