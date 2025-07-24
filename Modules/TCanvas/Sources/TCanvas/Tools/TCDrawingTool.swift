import TTypes

class TCDrawingTool: TCBrushTool {
    override func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
        super.handleFingerTouch(touch, ctm: ctm, brush: brush)
        for segment in generatedSegments {
            canvasPresenter?.draw(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenDrawing()
        generatedSegments = []
    }
    
    override func handlePencilTouch(
        _ touch: TCTouch,
        ctm: TTTransform,
        brush: TCBrush
    ) {
        super.handlePencilTouch(touch, ctm: ctm, brush: brush)
        for segment in generatedSegments {
            canvasPresenter?.draw(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenDrawing()
        generatedSegments = []
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterDrawing()
    }
}

