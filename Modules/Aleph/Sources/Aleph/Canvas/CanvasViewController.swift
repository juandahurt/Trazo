import MetalKit
import Tartarus
import UIKit

class CanvasViewController: UIViewController {
    var state: CanvasState!
    let gestureController = GestureController()
    let transformer = Transformer()
    let renderer: CanvasRenderer
    
    init(canvasSize: CGRect) {
        state = CanvasState(
            canvasSize: .init(
                width: Float(canvasSize.width),
                height: Float(canvasSize.height)
            )
        )
        renderer = .init(
            canvasSize: .init(
                width: Float(canvasSize.width),
                height: Float(canvasSize.height)
            )
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        let canvasView = CanvasView()
        canvasView.delegate = self
//        canvasView.clearColor = .init(
//            red: Double(renderer.ctx.clearColor.r),
//            green: Double(renderer.ctx.clearColor.g),
//            blue: Double(renderer.ctx.clearColor.b),
//            alpha: 1
//        )
        view = canvasView
    }
    
    override func viewDidLoad() {
        let fingerRecognizer = FingerGestureRecognizer()
        fingerRecognizer.fingerGestureDelegate = self
        view.addGestureRecognizer(fingerRecognizer)
        
        state.contentScaleFactor = Float(view.contentScaleFactor)
        setupCanvas()
        
        gestureController.delegate = self
        renderer.frameRequester = self
        
        renderer.notifyChange()
    }
    
    func setupCanvas() {
//        renderer.ctx.tileSize = state.tileSize
//        state.renderableTexture = TextureManager.makeTiledTexture(
//            named: "Renderable texture",
//            rows: 8,
//            columns: 8,
//            tileSize: state.tileSize,
//            canvasSize: state.canvasSize
//        )
//        state.grayscaleTexture = TextureManager.makeTiledTexture(
//            named: "Grayscale texture",
//            rows: 8,
//            columns: 8,
//            tileSize: state.tileSize,
//            canvasSize: state.canvasSize
//        )
//        state.strokeTexture = TextureManager.makeTiledTexture(
//            named: "Stroke texture",
//            rows: 8,
//            columns: 8,
//            tileSize: state.tileSize,
//            canvasSize: state.canvasSize
//        )
//        
//        // layers
//        let bgTexture = TextureManager.makeTiledTexture(
//            named: "Background texture",
//            rows: 8,
//            columns: 8,
//            tileSize: state.tileSize,
//            canvasSize: state.canvasSize
//        )
////        renderer.fillTexture(bgTexture, color: .white, using: renderer.commandBuffer!)
//        let bgLayer = Layer(named: "Background", texture: bgTexture)
//        let firstLayerTexture = TextureManager.makeTiledTexture(
//            named: "Background texture",
//            rows: 8,
//            columns: 8,
//            tileSize: state.tileSize,
//            canvasSize: state.canvasSize
//        )
//        let firstLayer = Layer(named: "Background", texture: bgTexture)
//        
//        state.layers = [bgLayer, firstLayer]
//        state.currentLayerIndex = 1
//        
//        state.intermediateTexture = TextureManager
//            .makeTexture(
//                ofSize: state.canvasSize,
//                label: "Intermediate texture"
//            )
        
//        renderer
//            .merge(
//                layers: state.layers,
//                currentLayerIndex: state.currentLayerIndex,
//                renderableTexture: state.renderableTexture!,
//                strokeTexture: state.strokeTexture!,
//                usingStrokeTexture: false
//            )
    }
}

extension CanvasViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let viewSize = Float(size.height)
        let aspect = Float(size.width) / Float(size.height)
        let rect = Rect(
            x: -viewSize * aspect * 0.5,
            y: Float(viewSize) * 0.5,
            width: Float(viewSize * aspect),
            height: Float(viewSize)
        )
        renderer.updateCurrentProjection(
            .init(
                ortho: rect,
                near: 0,
                far: 1
            )
        )
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        renderer.draw(drawable: drawable)
//        guard
//            let drawable = view.currentDrawable,
//            var currentRenderPassDescriptor = view.currentRenderPassDescriptor
//        else { return }
//        print(drawCalls, segmentCount)
//        print("debug: dentro de draw")
//        print("debug: empieza a procesar \(segmentBuffer.count()) segmentos pendientes")
//        let segments = segmentBuffer.drain()
//        if !segments.isEmpty {
//            renderer.draw(
//                segments: segments,
//                shapeTextureId: state.selectedBrush.shapeTextureID,
//                grayscaleTexture: state.grayscaleTexture!,
//                strokeTexture: state.strokeTexture!
//            )
//            print("debug: despues de dibujar y colorear")
//            print(renderer.ctx.getDirtyIndices())
//            renderer
//                .merge(
//                    layers: state.layers,
//                    currentLayerIndex: state.currentLayerIndex,
//                    renderableTexture: state.renderableTexture!,
//                    strokeTexture: state.strokeTexture!
//                )
//            print("debug: despues de merge")
//            print("debug: termina procesar segmentos pendientes")
//        }
//        
//        let encoder = renderer.commandBuffer?.makeRenderCommandEncoder(
//            descriptor: currentRenderPassDescriptor
//        )
//        renderer.copy(
//            sourceTiledTexture: state.renderableTexture!,
//            destTextureID: state.intermediateTexture!
//        )
//        print("debug: despues de copy")
//        renderer.drawTexture(
//            state.intermediateTexture!,
//            on: drawable.texture,
//            using: encoder!
//        )
//        encoder?.endEncoding()
//        drawCalls += 1
//        renderer.present(drawable)
//        renderer.commit()
//        renderer.reset()
//        
//        print("draw")
    }
}

// MARK: - Gesture delegate
extension CanvasViewController: @preconcurrency GestureControllerDelegate {
    func gestureControllerDidStartTransform(
        _ controller: GestureController,
        touchesMap: [Int : [Touch]]
    ) {
        transformer.initialize(withTouches: touchesMap)
    }
    
    func gestureControllerDidTransform(
        _ controller: GestureController,
        touchesMap: [Int : [Touch]]
    ) {
        transformer.transform(currentTouches: touchesMap)
        renderer.updateCurrentTransform(transformer.transform)
        renderer.notifyChange()
    }
    
    func gestureControllerDidStartPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        renderer.handleInput(touch)
    }
    
    func gestureControllerDidPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        renderer.handleInput(touch)
    }
}

// MARK: - Finger gesture delegate
extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        let touches = touches.map { Touch(touch: $0, in: view) }
        gestureController.handleFingerTouches(touches)
    }
}

extension CanvasViewController: @MainActor FrameRequester {
    func requestFrame() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            view.setNeedsDisplay()
        }
    }
}
