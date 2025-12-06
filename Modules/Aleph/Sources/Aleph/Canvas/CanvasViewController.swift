import MetalKit
import Tartarus
import UIKit

class CanvasViewController: UIViewController {
    var state: CanvasState!
    let renderer = Renderer()
    let gestureController = GestureController()
    let transformer = Transformer()
    let currentTool = BrushTool()
    
    init(canvasSize: CGRect) {
        state = CanvasState(
            canvasSize: .init(
                width: Float(canvasSize.width),
                height: Float(canvasSize.height)
            )
        )
        
        super.init(nibName: nil, bundle: nil)
        
        currentTool.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        let canvasView = CanvasView()
        canvasView.delegate = self
        canvasView.clearColor = .init(
            red: Double(renderer.ctx.clearColor.r),
            green: Double(renderer.ctx.clearColor.g),
            blue: Double(renderer.ctx.clearColor.b),
            alpha: 1
        )
        view = canvasView
    }
    
    override func viewDidLoad() {
        let fingerRecognizer = FingerGestureRecognizer()
        fingerRecognizer.fingerGestureDelegate = self
        view.addGestureRecognizer(fingerRecognizer)
        
        state.contentScaleFactor = Float(view.contentScaleFactor)
        setupCanvas()
        
        gestureController.delegate = self
    }
    
    func setupCanvas() {
        renderer.ctx.tileSize = state.tileSize
        state.renderableTexture = TextureManager.makeTiledTexture(
            named: "Renderable texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        state.grayscaleTexture = TextureManager.makeTiledTexture(
            named: "Grayscale texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        state.strokeTexture = TextureManager.makeTiledTexture(
            named: "Stroke texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        
        // layers
        let bgTexture = TextureManager.makeTiledTexture(
            named: "Background texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        renderer.fillTexture(bgTexture, color: .white)
        let bgLayer = Layer(named: "Background", texture: bgTexture)
        let firstLayerTexture = TextureManager.makeTiledTexture(
            named: "Background texture",
            rows: 8,
            columns: 8,
            tileSize: state.tileSize,
            canvasSize: state.canvasSize
        )
        let firstLayer = Layer(named: "Background", texture: bgTexture)
        
        state.layers = [bgLayer, firstLayer]
        state.currentLayerIndex = 1
        
        mergeLayers()
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
        
        renderer.ctx.canvasSize = Size(
            width: Float(size.width),
            height: Float(size.height)
        )
        renderer.ctx.cpm = .init(
            ortho: rect,
            near: 0,
            far: 1
        )
    }
    
    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            var currentRenderPassDescriptor = view.currentRenderPassDescriptor,
            let encoder = renderer.commandBuffer?.makeRenderCommandEncoder(
                descriptor: currentRenderPassDescriptor
            )
        else { return }
        renderer.drawTiledTexture(
            state.renderableTexture!,
            on: drawable.texture,
            using: encoder
        )
        renderer.present(drawable)
        renderer.commit()
        renderer.reset()
        
        print("draw")
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
        renderer.ctx.ctm = transformer.transform
        view.setNeedsDisplay()
    }
    
    func gestureControllerDidStartPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        currentTool.handleFingerTouch(touch, ctm: renderer.ctx.ctm)
    }
    
    func gestureControllerDidPanWithFinger(
        _ controller: GestureController,
        touch: Touch
    ) {
        currentTool.handleFingerTouch(touch, ctm: renderer.ctx.ctm)
    }
}

// MARK: - Finger gesture delegate
extension CanvasViewController: FingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        let touches = touches.map { Touch(touch: $0, in: view) }
        gestureController.handleFingerTouches(touches)
    }
}

// MARK: - Brush tool delegate
extension CanvasViewController: @preconcurrency BrushToolDelegate {
    func brushTool(_ tool: BrushTool, didGenerateSegments segments: [StrokeSegment]) {
        for segment in segments {
            draw(segment: segment)
        }
        mergeLayers()
        view.setNeedsDisplay()
    }
}

// MARK: - Rendering
extension CanvasViewController {
    func mergeLayers(usingStrokeTexture: Bool = true) {
        //            clearRenderableTexture()
        renderer.fillTexture(state.renderableTexture!, color: .clear, onlyDirtTiles: true)
        for index in stride(from: state.layers.count - 1, to: -1, by: -1) {
            //            if !state.layers[index].isVisible { continue }
            if index == state.currentLayerIndex && usingStrokeTexture {
                renderer.merge(
                    state.renderableTexture!,
                    with: state.strokeTexture!,
                    on: state.renderableTexture!
                )
            } else {
                renderer.merge(
                    state.renderableTexture!,
                    with: state.layers[index].texture,
                    on: state.renderableTexture!
                )
            }
        }
    }
    
    func draw(segment: StrokeSegment) {
        guard
            let grayscaleTexture = state.grayscaleTexture,
            let strokeTexture = state.strokeTexture
        else { return }
        renderer.draw(segment: segment, on: grayscaleTexture)
        renderer
            .colorize(
                texture: grayscaleTexture,
                withColor: .init([0, 0, 0, 1]),
                on: strokeTexture
            )
    }
}
