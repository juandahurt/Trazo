import TTypes

protocol TCTool {
    var canvasPresenter: TCCanvasPresenter? { get set }
    
    func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush)
    func handlePencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush)
    func handleUpdatedPencilTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush)
}
