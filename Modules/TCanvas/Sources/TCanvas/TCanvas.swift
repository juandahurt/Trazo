import TGraphics
import TPainter
import TTypes
import simd
import UIKit

@MainActor
public class TCanvas {
    let graphics = TGraphics()
    var state = TCState()
    var renderableView: TGRenderableView?
    let gestureController = TCCanvasGestureController()
    let transformer = TCTransformer()
    var painter = TPainter()
    
    public init() {}
    
    @MainActor
    public func load(in view: UIView) {
        graphics.load()
        setupRenderableView(in: view)
        
        guard let renderableView else { return }
        
        let viewSize: simd_long2 = [
            Int(view.bounds.width * renderableView.contentScaleFactor),
            Int(view.bounds.height * renderableView.contentScaleFactor)
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
        
        // colorized texture
        guard let colorizedTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Colorized texture"
        ) else {
            return
        }
        state.colorizedTexture = colorizedTextureId
        
        // stroke texture
        guard let strokeTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Stroke texture"
        ) else {
            return
        }
        state.strokeTexture = strokeTextureId
        
        mergeLayers()
        
        renderableView.setNeedsDisplay()
    }
   
    @MainActor
    private func setupRenderableView(in view: UIView) {
        let renderableView = graphics.makeRenderableView()
        renderableView.renderableDelegate = self
        view.addSubview(renderableView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: renderableView.topAnchor),
            view.leadingAnchor.constraint(equalTo: renderableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: renderableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: renderableView.bottomAnchor),
        ])
        
        // gestures
        let fingerGestureRecognizer = TCFingerGestureRecognizer()
        renderableView.addGestureRecognizer(fingerGestureRecognizer)
        fingerGestureRecognizer.fingerGestureDelegate = self
        
        self.renderableView = renderableView
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
    
    func mergeLayers() {
        graphics.pushDebugGroup("Merge layers")
        for index in stride(from: state.layers.count - 1, to: -1, by: -1) {
//            if !state.layers[index].isVisible { continue }
            var layerTextureId = state.layers[index].textureId
            graphics.pushDebugGroup("Merge layer \(layerTextureId) with renderable")
            if index == state.currentLayerIndex {
                layerTextureId = state.strokeTexture
            }
            graphics.merge(
                state.renderableTexture,
                with: layerTextureId,
                on: state.renderableTexture
            )
            graphics.popDebugGroup()
        }
        graphics.popDebugGroup()
    }
    
    func drawPoints(_ points: [TGRenderablePoint]) {
        graphics.pushDebugGroup("Draw grayscale points")
        graphics.drawGrayscalePoints(
            points,
            numPoints: points.count, // TODO: remove count
            in: state.grayscaleTexture,
            transform: state.ctm.inverse,
            projection: state.projectionMatrix
        )
        graphics.popDebugGroup()
        graphics.pushDebugGroup("Colorize")
        graphics.colorize(
            grayscaleTexture: state.grayscaleTexture,
            withColor: [0.2, 0.1, 0.8, 1],
            on: state.colorizedTexture
        )
        graphics.popDebugGroup()
        graphics.pushDebugGroup("Merge stroke texture with colorized texture")
        graphics.merge(
            state.strokeTexture,
            with: state.colorizedTexture,
            on: state.strokeTexture
        )
        graphics.popDebugGroup()
    }
}

extension TCanvas: TGRenderableViewDelegate {
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

extension TCanvas: TCFingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        guard let renderableView else { return }
        let touches = touches.map {
            TTTouch(
                id: $0.hashValue,
                location: $0.location(fromCenterOfView: renderableView),
                phase: $0.phase
            )
        }
        let res = gestureController.handleFingerTouches(touches)
        handleFingerGestureResult(res)
    }
}

extension TCanvas {
    private func handleFingerGestureResult(
        _ result: TCCanvasGestureController.TCFingerGestureResult
    ) {
        switch result {
        case .draw(let touch):
            let points = painter.generatePoints(forTouch: touch)
            drawPoints(points)
            clearRenderableTexture()
            mergeLayers()
            clearGrayscaleTexture()
            state.currentGesture = .drawWithFinger
        case .transform(let touchesMap):
            if state.currentGesture != .transform {
                transformer.reset()
            }
            if !transformer.isInitialized {
                transformer.initialize(withTouches: touchesMap)
            }
            transformer.transform(usingCurrentTouches: touchesMap)
            state.ctm = transformer.transform
            state.currentGesture = .transform
            print("transform")
        case .unknown:
            print("uknown gesture")
            state.currentGesture = .none
        case .liftedFingers:
            painter.endStroke()
            state.currentGesture = .none
        }
        
        renderableView?.setNeedsDisplay()
    }
}
