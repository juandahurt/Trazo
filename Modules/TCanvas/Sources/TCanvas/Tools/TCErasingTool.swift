import TTypes

class TCErasingTool: TCBrushTool {
    override func onFingerTouchHandleFinish(touch: TCTouch, segments: [TCStrokeSegment]) {
        if touch.phase == .began {
            canvasPresenter?.copyCurrrentLayerToStrokeTexture()
        }
        for segment in segments {
            canvasPresenter?.erase(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenErasing()
    }
    
    override func onPencilTouchHandleFinish(touch: TCTouch, segments: [TCStrokeSegment]) {
        if touch.phase == .began {
            canvasPresenter?.copyCurrrentLayerToStrokeTexture()
        }
        
        for segment in segments {
            canvasPresenter?.erase(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenErasing()
    }
    
    override func onUpdatedPencilTouchHandleFinish() {
        canvasPresenter?.mergeLayersWhenErasing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterErasing()
    }
}
