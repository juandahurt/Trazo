import Tartarus

class BrushTool {
    var touches: [Touch] = []
    let strokeGenerator = StrokeGenerator()
    
    func handleFingerTouch(_ touch: Touch, ctm: Transform) {
        strokeGenerator.add(touch)
        strokeGenerator.generateSegmentsForLastTouch(ctm: ctm)
        print("handling touch in tool")
    }
}
