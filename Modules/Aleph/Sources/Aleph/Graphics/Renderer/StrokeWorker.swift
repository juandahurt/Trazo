import CoreFoundation
import Tartarus

class StrokeWorker {
    let strokeSystem = StrokeSystem()
    let tileSystem = TileSystem()
    let backgroundQueue = DispatchQueue(label: "")
    
    func submit(
        _ touch: Touch,
        ctm: Transform,
        boundingBoxes: [Rect],
        completion: @escaping (FrameContribution) -> Void
    ) {
        backgroundQueue.async { [weak self] in
            guard let self else { return }
            let segments = strokeSystem.process(touch, ctm: .identity)
            print("generated:", segments.count)
            guard !segments.isEmpty else { return }
            let dirtyTiles = tileSystem.invalidate(
                with: segments,
                boundingBoxes: boundingBoxes
            )
            print("dirty indices:", dirtyTiles)
            let frameContribution = FrameContribution(
                segments: segments,
                dirtyTiles: dirtyTiles
            )
            
            completion(frameContribution)
        }
    }
}
