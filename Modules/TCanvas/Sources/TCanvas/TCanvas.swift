import TGraphics
import UIKit

public class TCanvas {
    let graphics = TGraphics()
    
    @MainActor
    public func load(in view: UIView) {
        graphics.load()
        
        // MARK: create default textures
        guard let bgTextureId = graphics.makeTexture(
            ofSize: [
                Int(view.bounds.width),
                Int(view.bounds.height)
            ],
            label: "Background"
        ) else { return }
        graphics.fillTexture(bgTextureId, with: [1, 1, 1, 1])
        
        guard let texture1 = graphics.makeTexture(
            ofSize: [
                Int(view.bounds.width),
                Int(view.bounds.height)
            ],
            label: "Texture 1"
        ) else { return }
        // TODO: add layers to texture manager
        
        let renderableView = graphics.makeRenderableView()
        renderableView.renderableDelegate = self
        view.addSubview(renderableView)
    }
}

extension TCanvas: TGRenderableViewDelegate {
    public func provideTextureToRender() -> any MTLTexture {
        fatalError("not implemented")
    }
}
