import Combine
import TGraphics
import TPainter
import TTypes
import simd
import UIKit

@MainActor
class TCViewModel {
    let graphics = TGraphics()
    var state = TCState()
    let gestureController = TCCanvasGestureController()
    let transformer: TCTransformer
    var painter: TPainter
    
    let renderableViewNeedsDisplaySubject = PassthroughSubject<Void, Never>()
    
    private var disposeBag = Set<AnyCancellable>()
    
    public init(config: TCConfig) {
        transformer = TCTransformer()
        painter = .init(brush: config.brush)
        state.isTransformEnabled = config.isTransformEnabled
    }
    
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
    
    func makeRenderableView() -> TGRenderableView {
        graphics.makeRenderableView()
    }
    
    func updateBrush(with brush: TPBrush) {
        painter.brush = brush
    }
   
    func updateTool(_ tool: TCTool) {
        state.tool = tool
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
    
    func updateCurrentLayerTexture() {
        if state.tool == .draw {
            graphics.merge(
                state.strokeTexture,
                with: state.layers[state.currentLayerIndex].textureId,
                on: state.layers[state.currentLayerIndex].textureId
            )
        }
        if state.tool == .erase {
            graphics.copy(
                texture: state.strokeTexture,
                on: state.layers[state.currentLayerIndex].textureId
            )
        }
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
    
    func drawPoints(_ points: [TGRenderablePoint]) {
        guard !points.isEmpty else { return }
        graphics.pushDebugGroup("Draw grayscale points")
        graphics.drawGrayscalePoints(
            points,
            numPoints: points.count, // TODO: remove count
            in: state.grayscaleTexture,
            opacity: painter.brush.opacity,
            shapeTextureId: -1, // TODO: pass correct id
            transform: state.ctm.inverse,
            projection: state.projectionMatrix
        )
        graphics.popDebugGroup()
        graphics.pushDebugGroup("Colorize")
        graphics.colorize(
            grayscaleTexture: state.grayscaleTexture,
            withColor: [0.2, 0.1, 0.8, 1],
            on: state.strokeTexture
        )
        graphics.popDebugGroup()
    }
    
    func erasePoints(_ points: [TGRenderablePoint]) {
        guard !points.isEmpty else { return }
        graphics.pushDebugGroup("Draw grayscale points")
        graphics.drawGrayscalePoints(
            points,
            numPoints: points.count, // TODO: remove count
            in: state.grayscaleTexture,
            opacity: painter.brush.opacity,
            shapeTextureId: -1, // TODO: pass correct id
            transform: state.ctm.inverse,
            projection: state.projectionMatrix,
            clearBackground: true
        )
        graphics.popDebugGroup()
        graphics.pushDebugGroup("Substract points")
        graphics.substract(
            textureA: state.layers[state.currentLayerIndex].textureId,
            textureB: state.grayscaleTexture,
            on: state.strokeTexture
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
    func handlePencilTouch(_ touch: TTTouch) {
        painter.generatePoints(forTouch: touch, ctm: state.ctm)
        drawPoints(painter.points)
        mergeLayers(usingStrokeTexture: true)
        
        if touch.phase == .ended || touch.phase == .cancelled {
            painter.endStroke()
            
            // update current layer with the stroke texture
            updateCurrentLayerTexture()
            // update the renderable texture with the updated layer
            mergeLayers(usingStrokeTexture: false)
            
            clearGrayscaleTexture()
            clearStrokeTexture()
        }
        
        renderableViewNeedsDisplaySubject.send(())
    }
    
    func handleFingerTouches(_ touches: [TTTouch]) {
        gestureController.handleFingerTouches(touches)
    }
}

extension TCViewModel {
    private func handleFingerGestureResult(
        _ result: TCCanvasGestureController.TCFingerGestureEvent
    ) {
        switch result {
        case .draw(let touch):
            painter.generatePoints(forTouch: touch, ctm: state.ctm)
            switch state.tool {
            case .draw:
                drawPoints(painter.points)
                mergeLayers(usingStrokeTexture: true)
            case .erase:
                if touch.phase == .began {
                    graphics
                        .copy(
                            texture: state.layers[state.currentLayerIndex].textureId,
                            on: state.strokeTexture
                        )
                }
                erasePoints(painter.points)
                mergeLayers(usingStrokeTexture: true, ignoringCurrentTexture: true)
            }
        case .drawCanceled:
            painter.endStroke()
            clearGrayscaleTexture() // just in case :)
        case .transform(let touchMap):
            guard state.isTransformEnabled else { return }
            transformer.transform(usingCurrentTouches: touchMap)
            state.ctm = transformer.transform
        case .transformInit(let touchMap):
            transformer.reset()
            transformer.initialize(withTouches: touchMap)
        case .idle: return
        case .drawEnded:
            painter.endStroke()
            
            // update current layer with the stroke texture
            updateCurrentLayerTexture()
            // update the renderable texture with the updated layer
            mergeLayers(usingStrokeTexture: false)
            
            clearGrayscaleTexture()
            clearStrokeTexture()
        }
        
        renderableViewNeedsDisplaySubject.send(())
    }
}
