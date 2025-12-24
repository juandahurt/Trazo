import MetalKit

class CanvasView: MTKView {
    init() {
        super.init(frame: .zero, device: GPU.device)
        isPaused = true
        enableSetNeedsDisplay = true
        colorPixelFormat = .rgba8Unorm
        clearColor = .init(
            red: 0.2,
            green: 0.4,
            blue: 0.2,
            alpha: 1
        )
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
