import MetalKit

class CanvasView: MTKView {
    init() {
        super.init(frame: .zero, device: GPU.device)
        isPaused = true
        enableSetNeedsDisplay = true
        colorPixelFormat = .rgba8Unorm
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
