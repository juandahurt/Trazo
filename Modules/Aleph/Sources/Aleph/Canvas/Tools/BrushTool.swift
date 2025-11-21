import Tartarus

protocol BrushToolDelegate: AnyObject {
    func brushTool(_ tool: BrushTool, didGenerateSegments segments: [StrokeSegment])
}

class BrushTool {
    var touches: [Touch] = []
    let strokeGenerator = StrokeGenerator()
    
    weak var delegate: BrushToolDelegate?
    
    func handleFingerTouch(_ touch: Touch, ctm: Transform) {
        strokeGenerator.add(touch)
        let segments = strokeGenerator.generateSegmentsForLastTouch(ctm: ctm)
        guard !segments.isEmpty else { return }
        delegate?.brushTool(self, didGenerateSegments: segments)
    }
}
