import TTypes

class TCDrawingTool: TCBrushTool {
    override func onFingerTouchHandleFinish(segments: [TCDrawableSegment]) {
        for segment in segments {
            canvasPresenter?.draw(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func onPencilTouchHandleFinish(segments: [TCDrawableSegment]) {
        for segment in segments {
            canvasPresenter?.draw(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func onUpdatedPencilTouchHandleFinish() {
        canvasPresenter?.draw(stroke: drawableStroke)
    }
    
//    override func handleUpdatedPencilTouch(
//        _ touch: TCTouch,
//        ctm: TTTransform,
//        brush: TCBrush
//    ) {
//        super.handleUpdatedPencilTouch(touch, ctm: ctm, brush: brush)
//        canvasPresenter?.draw(stroke: drawableStroke)
//    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterDrawing()
    }
}

