import MetalKit

class CanvasView: MTKView {
    init() {
        super.init(frame: .zero, device: GPU.device)
        clearColor = .init(red: 0.1, green: 0, blue: 0.5, alpha: 1)        
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
