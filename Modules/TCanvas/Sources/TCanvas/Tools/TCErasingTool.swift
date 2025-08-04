import TTypes

class TCErasingTool: TCBrushTool {
    override func onFingerTouchHandleFinish(touch: TCTouch, segments: [TCDrawableSegment]) {
        if touch.phase == .began {
            canvasPresenter?.copyCurrrentLayerToStrokeTexture()
        }
        for segment in segments {
            canvasPresenter?.erase(segment: segment)
        }
        canvasPresenter?.mergeLayersWhenErasing()
    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterErasing()
    }
}
