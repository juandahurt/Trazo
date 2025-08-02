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
        canvasPresenter?.mergeLayersWhenDrawing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterDrawing()
    }
}

