import Combine
import TGraphics
import TTypes
import simd
import UIKit

protocol TCCanvasPresenter: AnyObject {
    // draw
    func draw(segment: TCDrawableSegment)
    func mergeLayersWhenDrawing()
    func updateCurrentLayerAfterDrawing()
    // erase
    func erase(segment: TCDrawableSegment)
    func mergeLayersWhenErasing()
    func copyCurrrentLayerToStrokeTexture()
    func updateCurrentLayerAfterErasing()
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
        
        guard let grayScaleTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Grayscale Texture"
        ) else { return }
        state.grayscaleTexture = grayScaleTextureId
        
        // MARK: - layers setup
        guard let bgTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Background"
        ) else { return }
        graphics.fillTexture(bgTextureId, with: [1, 1, 1, 1])
        
        guard let texture1Id = graphics.makeTexture(
            ofSize: viewSize,
            label: "Texture 1"
        ) else { return }
        
        // layers
        let texture1Layer = TCLayer(textureId: texture1Id, name: "Texture 1")
        let bgLayer = TCLayer(textureId: bgTextureId, name: "Background")
        for layer in [bgLayer, texture1Layer] {
            state.addLayer(layer)
        }
        state.currentLayerIndex = 1
        
        // renderable texture
        guard let renderableTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Renderable texture"
        ) else {
            return
        }
        state.renderableTexture = renderableTextureId
        
        // stroke texture
        guard let strokeTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Stroke texture"
        ) else {
            return
        }
        state.strokeTexture = strokeTextureId
        
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
    
    func clearRenderableTexture() {
        graphics.pushDebugGroup("Clear renderable texture")
        graphics.fillTexture(state.renderableTexture, with: [0, 0, 0, 0])
        graphics.popDebugGroup()
    }
    
    func clearStrokeTexture() {
        graphics.pushDebugGroup("Clear renderable texture")
        graphics.fillTexture(state.strokeTexture, with: [0, 0, 0, 0])
        graphics.popDebugGroup()
    }
    
    func clearGrayscaleTexture() {
        graphics.pushDebugGroup("Clear grasycale texture")
        graphics.fillTexture(state.grayscaleTexture, with: [0, 0, 0, 0])
        graphics.popDebugGroup()
    }
    
    func mergeLayers(usingStrokeTexture: Bool, ignoringCurrentTexture: Bool = false) {
        graphics.pushDebugGroup("Merge layers")
        clearRenderableTexture()
        for index in stride(from: state.layers.count - 1, to: -1, by: -1) {
            //            if !state.layers[index].isVisible { continue }
            if index == state.currentLayerIndex && usingStrokeTexture {
                graphics.merge(
                    state.renderableTexture,
                    with: state.strokeTexture,
                    on: state.renderableTexture
                )
            }
            if index == state.currentLayerIndex && ignoringCurrentTexture {
                continue
            }
            graphics.merge(
                state.renderableTexture,
                with: state.layers[index].textureId,
                on: state.renderableTexture
            )
        }
        graphics.popDebugGroup()
    }
    
    func drawGrayscalePoints(points: [TGRenderablePoint], pointsCount: Int) {
        graphics.pushDebugGroup("Draw grayscale points")
        graphics.drawGrayscalePoints(
            points,
            numPoints: pointsCount,
            in: state.grayscaleTexture,
            opacity: state.brush.opacity,
            shapeTextureId: -1, // TODO: pass correct id
            transform: state.ctm.inverse,
            projection: state.projectionMatrix
        )
        graphics.popDebugGroup()
    }
}

extension TCViewModel: TGRenderableViewDelegate {
    public func renderableView(
        _ renderableView: TGRenderableView,
        willPresentCurrentDrawable currentDrawable: any CAMetalDrawable
    ) {
        graphics.pushDebugGroup("Present canvas")
        graphics.drawTexture(
            state.renderableTexture,
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
            currentTool.handleFingerTouch(touch, ctm: state.ctm, brush: state.brush)
        case .fingerDrawCanceled:
            if let brushTool = currentTool as? TCBrushTool {
                brushTool.endStroke()
            }
            clearGrayscaleTexture() // just in case :)
            clearStrokeTexture()
        case .drawEnded:
            if let brushTool = currentTool as? TCBrushTool {
                brushTool.endStroke()
            }
            // update the renderable texture with the updated layer
            mergeLayers(usingStrokeTexture: false)
            clearGrayscaleTexture()
            clearStrokeTexture()
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
