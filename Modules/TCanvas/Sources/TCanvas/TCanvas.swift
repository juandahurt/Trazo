import TGraphics
import simd
import UIKit

public class TCanvas {
    let graphics = TGraphics()
    var state = TCState()
    
    @MainActor
    public func load(in view: UIView) {
        graphics.load()
        
        let viewSize: simd_long2 = [Int(view.bounds.width), Int(view.bounds.height)]
        
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
        
        // rendeable texture
        guard let renderableTextureId = graphics.makeTexture(ofSize: viewSize) else {
            return
        }
        state.renderableTexture = renderableTextureId
        
        // TODO: merge layers
        
        renderableView.setNeedsDisplay()
    }
}

extension TCanvas: TGRenderableViewDelegate {
    public func provideTextureToRender() -> any MTLTexture {
        guard let renderableTexture = graphics.texture(byId: state.renderableTexture) else {
            fatalError("renderable texture does not exist!")
        }
        return renderableTexture
    }
}
