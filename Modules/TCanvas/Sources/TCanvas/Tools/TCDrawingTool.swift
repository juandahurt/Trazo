import TTypes

class TCDrawingTool: TCBrushTool {
    override func onFingerTouchHandleFinish(touch: TCTouch, segments: [TCStrokeSegment]) {
        for segment in segments {
            canvasPresenter?.draw(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func onPencilTouchHandleFinish(touch: TCTouch, segments: [TCStrokeSegment]) {
        for segment in segments {
            canvasPresenter?.draw(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func onUpdatedPencilTouchHandleFinish() {
        canvasPresenter?.draw(stroke: drawableStroke)
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterDrawing()
    }
}

