import CoreFoundation
import Tartarus

class StrokeWorker {
    let strokeSystem = StrokeSystem()
    let tileSystem = TileSystem()
    let backgroundQueue = DispatchQueue(label: "")
    
    func submit(
        _ touch: Touch,
        ctm: Transform,
        brush: Brush,
        tileSize: Size,
        cols: Int,
        completion: @escaping (FrameContribution) -> Void
    ) {
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            let segments = strokeSystem.process(touch, brush: brush, ctm: ctm)
            guard !segments.isEmpty else { return }
            let dirtyTiles = tileSystem.invalidate(
                with: segments,
                cols: cols,
                tileSize: tileSize,
                ctm: ctm
            )
            let frameContribution = FrameContribution(
                segments: segments,
                dirtyTiles: dirtyTiles
            )
            
            completion(frameContribution)
        }
    }
}
