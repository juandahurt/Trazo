import TTypes

class TCErasingTool: TCBrushTool {
//    override func handleFingerTouch(_ touch: TCTouch, ctm: TTTransform, brush: TCBrush) {
//        super.handleFingerTouch(touch, ctm: ctm, brush: brush)
//        if touch.phase == .began {
//            canvasPresenter?.copyCurrrentLayerToStrokeTexture()
//        }
//        for segment in generatedSegments {
//            canvasPresenter?.erase(segment: segment)
//        }
//        canvasPresenter?.mergeLayersWhenErasing()
//        generatedSegments = []
//    }
    
    override func endStroke() {
        super.endStroke()
        canvasPresenter?.updateCurrentLayerAfterErasing()
    }
}
