import TGraphics
import simd
import UIKit

public class TCanvas {
    let graphics = TGraphics()
    var state = TCState()
    
    public init() {}
    
    @MainActor
    public func load(in view: UIView) {
        graphics.load()
        
        // renderable view
        let renderableView = graphics.makeRenderableView()
        renderableView.renderableDelegate = self
        view.addSubview(renderableView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: renderableView.topAnchor),
            view.leadingAnchor.constraint(equalTo: renderableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: renderableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: renderableView.bottomAnchor),
        ])
        
        let viewSize: simd_long2 = [
            Int(view.bounds.width * renderableView.contentScaleFactor),
            Int(view.bounds.height * renderableView.contentScaleFactor)
        ]
        
        // MARK: - layers setup
        guard let bgTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Background"
        ) else { return }
        graphics.fillTexture(bgTextureId, with: [1, 0.4, 0.2, 1])
        
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
        
        // rendeable texture
        guard let renderableTextureId = graphics.makeTexture(
            ofSize: viewSize,
            label: "Renderable texture"
        ) else {
            return
        }
        state.renderableTexture = renderableTextureId
        
        mergeLayers()
        
        renderableView.setNeedsDisplay()
    }
    
    func mergeLayers() {
        for index in stride(from: state.layers.count - 1, to: -1, by: -1) {
//            if !state.layers[index].isVisible { continue }
//            if index == state.currentLayerIndex && usingDrawingTexture {
//                layerTexture = state.drawingTexture
//            }
            graphics.merge(
                state.layers[index].textureId,
                with: state.renderableTexture,
                on: state.renderableTexture
            )
        }
    }
}

extension TCanvas: TGRenderableViewDelegate {
    public func renderableView(
        _ renderableView: TGRenderableView,
        willPresentCurrentDrawable currentDrawable: any CAMetalDrawable
    ) {
        print("will present drawable")
        graphics.drawTexture(
            state.renderableTexture,
            on: currentDrawable,
            clearColor: [0, 0, 0, 0],
            transform: state.ctm,
            projection: state.projectionMatrix
        )
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
