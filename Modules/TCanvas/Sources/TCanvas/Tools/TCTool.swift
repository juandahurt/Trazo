import TTypes

protocol TCTool {
    var canvasPresenter: TCCanvasPresenter? { get set }
    
    func handleTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush)
}
