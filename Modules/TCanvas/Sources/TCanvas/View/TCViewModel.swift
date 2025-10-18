import Combine
import TGraphics
import TTypes
import simd
import UIKit

protocol TCCanvasPresenter: AnyObject {
    // draw
    func draw(segment: TCDrawableSegment)
    func draw(stroke: TCDrawableStroke)
    func mergeLayersWhenDrawing()
    func updateCurrentLayerAfterDrawing()
    // erase
    func erase(segment: TCDrawableSegment)
    func erase(stroke: TCDrawableStroke)
    func mergeLayersWhenErasing()
    func copyCurrrentLayerToStrokeTexture()
    func updateCurrentLayerAfterErasing()
    
    // pencil
    func didFinishPencilGesture()
}


class TCViewModel {
    let graphics = TGraphics()
    var state: TCState
    let gestureController = TCCanvasGestureController()
    let transformer: TCTransformer
    var currentTool: TCTool = TCDrawingTool() {
        didSet {
            currentTool.canvasPresenter = self
        }
    }
    
    let renderableViewNeedsDisplaySubject = PassthroughSubject<Void, Never>()
    
    private var disposeBag = Set<AnyCancellable>()
    
    public init(config: TCConfig) {
        transformer = TCTransformer()
        state = .init(
            isTransformEnabled: config.isTransformEnabled,
            brush: config.brush
        )
        currentTool.canvasPresenter = self
    }
    
    @MainActor
    func load(using renderableView: TGRenderableView, size: CGSize) {
        graphics.load()
        setupSubscriptions()
        
        let viewSize: simd_long2 = [
            Int(size.width * renderableView.contentScaleFactor),
            Int(size.height * renderableView.contentScaleFactor)
        ]
        let magicNumber = 8 // TODO: use state.tilesPerRow || tilesPerColumn
        let tileSize = viewSize / magicNumber
        state.tileSize = simd_float2(tileSize)
        state.canvasSize = viewSize
        let cols = viewSize.x / tileSize.x
        let rows = viewSize.y / tileSize.y
        
        state.grayscaleTexture = graphics.makeTiledTexture(
            named: "Grayscale Texture",
            rows: rows,
            cols: cols,
            tileWidth: tileSize.x,
            tileHeight: tileSize.y
        )
        state.strokeTexture = graphics.makeTiledTexture(
            named: "Stroke texture",
            rows: rows,
            cols: cols,
            tileWidth: tileSize.x,
            tileHeight: tileSize.y
        )
       
        // MARK: - layers setup
        let bgTexture = graphics.makeTiledTexture(
            named: "Background texture",
            rows: rows,
            cols: cols,
            tileWidth: tileSize.x,
            tileHeight: tileSize.y
        )
        graphics.fillTexture(bgTexture, color: [1, 1, 1, 1])
        let texture1 = graphics.makeTiledTexture(
            named: "Layer 1 texture",
            rows: rows,
            cols: cols,
            tileWidth: tileSize.x,
            tileHeight: tileSize.y
        )
        let bgLayer = TCLayer(texture: bgTexture, name: "Background texture")
        let layer1 = TCLayer(texture: texture1, name: "Layer 1")
        
        for layer in [bgLayer, layer1] {
            state.addLayer(layer)
        }
        state.currentLayerIndex = 1
        
        // renderable texture
        let renderableTexture = graphics.makeTiledTexture(
            named: "Renderable texture",
            rows: rows,
            cols: cols,
            tileWidth: tileSize.x,
            tileHeight: tileSize.y
        )
        state.renderableTexture = renderableTexture
//        
//        // stroke texture
//        guard let strokeTextureId = graphics.makeTexture(
//            ofSize: viewSize,
//            label: "Stroke texture"
//        ) else {
//            return
//        }
//        state.strokeTexture = strokeTextureId
//        
        mergeLayers(usingStrokeTexture: false)
        
        renderableViewNeedsDisplaySubject.send(())
    }
    
    @MainActor
    func makeRenderableView() -> TGRenderableView {
        graphics.makeRenderableView()
    }
    
    func updateBrush(with brush: TCBrush) {
        state.brush = brush
    }
   
    func updateToolType(_ toolType: TCToolType) {
        currentTool =
        switch toolType {
        case .draw: TCDrawingTool()
        case .erase: TCErasingTool()
        }
    }
    
    private func setupSubscriptions() {
        gestureController.gestureEventSubject.sink { [weak self] res in
            guard let self else { return }
            handleFingerGestureResult(res)
        }.store(in: &disposeBag)
    }
    
    func clearRenderableTexture(dirtyTiles: Set<Int> = []) {
        guard let renderableTexture = state.renderableTexture else { return }
        graphics.pushDebugGroup("Clear renderable texture")
        graphics.fillTexture(
            renderableTexture,
            dirtyTiles: dirtyTiles,
            color: [0, 0, 0, 0]
        )
        graphics.popDebugGroup()
    }
    
    func clearStrokeTexture() {
        guard let strokeTexture = state.strokeTexture else { return }
        graphics.pushDebugGroup("Clear renderable texture")
        graphics
            .fillTexture(
                strokeTexture,
                dirtyTiles: state.dirtyTilesInStroke,
                color: [0, 0, 0, 0]
            )
        graphics.popDebugGroup()
    }
    
    func clearGrayscaleTexture() {
        guard let grayscaleTexture = state.grayscaleTexture else { return }
        graphics.pushDebugGroup("Clear grasycale texture")
        graphics.fillTexture(
            grayscaleTexture,
            dirtyTiles: state.dirtyTilesInStroke,
            color: [0, 0, 0, 0]
        )
        graphics.popDebugGroup()
    }
    
    func mergeLayers(
        usingStrokeTexture: Bool,
        ignoringCurrentTexture: Bool = false,
        dirtyTiles: Set<Int>? = nil
    ) {
        guard
            let renderableTexture = state.renderableTexture,
            let strokeTexture = state.strokeTexture
        else { return }
        graphics.pushDebugGroup("Merge layers")
        clearRenderableTexture(dirtyTiles: dirtyTiles ?? [])
        for index in stride(from: state.layers.count - 1, to: -1, by: -1) {
            //            if !state.layers[index].isVisible { continue }
            if index == state.currentLayerIndex && usingStrokeTexture {
                if let dirtyTiles {
                    for i in dirtyTiles {
                        graphics.merge(
                            renderableTexture.tiles[i].textureId,
                            with: strokeTexture.tiles[i].textureId,
                            on: renderableTexture.tiles[i].textureId
                        )
                    }
                } else {
                    for i in 0..<renderableTexture.tiles.count {
                        graphics.merge(
                            renderableTexture.tiles[i].textureId,
                            with: strokeTexture.tiles[i].textureId,
                            on: renderableTexture.tiles[i].textureId
                        )
                    }
                }
            }
            if index == state.currentLayerIndex && ignoringCurrentTexture {
                continue
            }
            if let dirtyTiles {
                for i in dirtyTiles {
                    graphics.merge(
                        renderableTexture.tiles[i].textureId,
                        with: state.layers[index].texture.tiles[i].textureId,
                        on: renderableTexture.tiles[i].textureId
                    )
                }
            } else {
                for i in 0..<renderableTexture.tiles.count {
                    graphics.merge(
                        renderableTexture.tiles[i].textureId,
                        with: state.layers[index].texture.tiles[i].textureId,
                        on: renderableTexture.tiles[i].textureId
                    )
                }
            }
        }
        graphics.popDebugGroup()
    }
    
    func drawGrayscalePoints(
        points: [TGRenderablePoint],
        clearBackground: Bool = false
    ) {
        guard let grayscaleTexture = state.grayscaleTexture else { return }
        graphics.pushDebugGroup("Draw grayscale points")
        graphics.drawGrayscalePoints(
            points,
            in: grayscaleTexture,
            dirtyTiles: state.dirtyTilesInStroke,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize,
            opacity: state.brush.opacity,
            shapeTextureId: -1, // TODO: pass correct id
            transform: state.ctm.inverse
        )
        graphics.popDebugGroup()
    }
}

extension TCViewModel: TGRenderableViewDelegate {
    public func renderableView(
        _ renderableView: TGRenderableView,
        willPresentCurrentDrawable currentDrawable: any CAMetalDrawable
    ) {
        guard let renderableTexture = state.renderableTexture else { return }
        graphics.pushDebugGroup("Present canvas")
        graphics.drawTexture(
            renderableTexture,
            on: currentDrawable,
            clearColor: state.clearColor,
            transform: state.ctm,
            projection: state.projectionMatrix
        )
        graphics.popDebugGroup()
    }
    
    public func renderableView(
        _ renderableView: TGRenderableView,
        sizeWillChange size: simd_float2
    ) {
        print("size will change")
        let viewSize = size.y
        let aspect = size.x / size.y
        let rect = CGRect(
            x: Double(-viewSize * aspect) * 0.5,
            y: Double(viewSize) * 0.5,
            width: Double(viewSize * aspect),
            height: Double(viewSize))
        
        state.projectionMatrix = simd_float4x4(
            ortho: rect,
            near: 0,
            far: 1
        )
    }
}

extension TCViewModel {
    func onPencilTouch(_ touch: TCTouch) {
        gestureController.handlePencilTouch(touch)
    }
    
    func onUpdatedPencilTouch(_ touch: TCTouch) {
        currentTool.handleUpdatedPencilTouch(touch, ctm: state.ctm, brush: state.brush)
        renderableViewNeedsDisplaySubject.send(())
    }
    
    func handleFingerTouches(_ touches: [TCTouch]) {
        gestureController.handleFingerTouches(touches)
    }
}

extension TCViewModel {
    private func handleFingerGestureResult(
        _ event: TCCanvasGestureController.TCGestureEvent
    ) {
        switch event {
        case .fingerDraw(let touch):
            // TODO: move this logic to another place
            var location = touch.location.applying(state.ctm.inverse)
            location.y *= -1
            location.x += Float(state.canvasSize.x) / 2
            location.y += Float(state.canvasSize.y) / 2
            
            let col = Int(location.x / state.tileSize.x)
            let row = Int(location.y / state.tileSize.y)
            
            let index = (row * 8) + col
            
            if index < 64 && index >= 0 {
                state.dirtyTilesInSegment.insert(index)
                state.dirtyTilesInStroke.insert(index)
            }
            
            currentTool.handleFingerTouch(touch, ctm: state.ctm, brush: state.brush)
        case .fingerDrawCanceled:
            if let brushTool = currentTool as? TCBrushTool {
                brushTool.endStroke()
            }
            clearGrayscaleTexture() // just in case :)
            clearStrokeTexture()
            
            state.dirtyTilesInStroke = []
        case .fingerDrawEnded:
            if let brushTool = currentTool as? TCBrushTool {
                brushTool.endStroke()
            }
            // update the renderable texture with the updated layer
            mergeLayers(usingStrokeTexture: false)
            clearGrayscaleTexture()
            clearStrokeTexture()
            state.dirtyTilesInStroke = []
        case .pencilDraw(let touch):
            currentTool.handlePencilTouch(touch, ctm: state.ctm, brush: state.brush)
        case .transformInit(let touchMap):
            transformer.reset()
            transformer.initialize(withTouches: touchMap)
        case .transform(let touchMap):
            guard state.isTransformEnabled else { return }
            transformer.transform(usingCurrentTouches: touchMap)
            state.ctm = transformer.transform
        case .idle: return
        }
        
        renderableViewNeedsDisplaySubject.send(())
    }
}
