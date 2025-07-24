import TGraphics

extension TCViewModel: TCCanvasPresenter {
    func draw(segment: TCDrawableSegment) {
        let points = segment.points
        let pointsCount = segment.pointsCount
        guard pointsCount > 0 else { return }
        drawGrayscalePoints(points: points, pointsCount: pointsCount)
        graphics.pushDebugGroup("Colorize")
        graphics.colorize(
            grayscaleTexture: state.grayscaleTexture,
            withColor: [0, 0, 0, 1],
            on: state.strokeTexture
        )
        graphics.popDebugGroup()
    }
    
    func mergeLayersWhenDrawing() {
        mergeLayers(usingStrokeTexture: true)
    }
    
    func updateCurrentLayerAfterDrawing() {
        graphics.merge(
            state.strokeTexture,
            with: state.layers[state.currentLayerIndex].textureId,
            on: state.layers[state.currentLayerIndex].textureId
        )
    }
    
    func erase(points: [TGRenderablePoint]) {
        guard !points.isEmpty else { return }
//        drawGrayscalePoints(points: points)
        graphics.pushDebugGroup("Substract points")
        graphics.substract(
            textureA: state.layers[state.currentLayerIndex].textureId,
            textureB: state.grayscaleTexture,
            on: state.strokeTexture
        )
        graphics.popDebugGroup()
    }
    
    func mergeLayersWhenErasing() {
        mergeLayers(usingStrokeTexture: true, ignoringCurrentTexture: true)
    }
    
    func copyCurrrentLayerToStrokeTexture() {
        graphics.copy(
            texture: state.layers[state.currentLayerIndex].textureId,
            on: state.strokeTexture
        )
    }
    
    func updateCurrentLayerAfterErasing() {
        graphics.copy(
            texture: state.strokeTexture,
            on: state.layers[state.currentLayerIndex].textureId
        )
    }
}
