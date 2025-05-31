import MetalKit

public class TGRenderableView: MTKView {
    weak var graphics: TGraphics?
    
    public weak var renderableDelegate: TGRenderableViewDelegate?
    
    init(graphics: TGraphics) {
        self.graphics = graphics
        super.init(frame: .zero, device: TGDevice.device)
      
        colorPixelFormat = .rgba8Unorm
        
        enableSetNeedsDisplay = true
        isPaused = true
        
        translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TGRenderableView: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: implement
    }

    public func draw(in view: MTKView) {
        guard
            let renderableDelegate,
            let currentDrawable
        else { return }
        
        let texture = renderableDelegate.provideTextureToRender()
        graphics?.present(currentDrawable)
    }
}

public protocol TGRenderableViewDelegate: AnyObject {
    func provideTextureToRender() -> MTLTexture
}
