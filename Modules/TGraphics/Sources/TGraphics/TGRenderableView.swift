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
        renderableDelegate?.renderableView(
            self,
            sizeWillChange: [Float(size.width), Float(size.height)]
        )
    }

    public func draw(in view: MTKView) {
        guard
            let renderableDelegate,
            let currentDrawable,
            let graphics
        else { return }
        
        renderableDelegate.renderableView(
            self,
            willPresentCurrentDrawable: currentDrawable
        )
        graphics.present(currentDrawable)
        graphics.commit()
        graphics.reset()
    }
}

public protocol TGRenderableViewDelegate: AnyObject {
    func renderableView(
        _ renderableView: TGRenderableView,
        willPresentCurrentDrawable currentDrawable: CAMetalDrawable
    )
    
    func renderableView(
        _ renderableView: TGRenderableView,
        sizeWillChange size: simd_float2
    )
}
