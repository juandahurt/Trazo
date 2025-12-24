import MetalKit
import Tartarus

struct FrameContext {
    let dirtyTiles: Set<Int>
    let segments: [StrokeSegment]
    let ctm: Transform
    let cpm: Transform
}
