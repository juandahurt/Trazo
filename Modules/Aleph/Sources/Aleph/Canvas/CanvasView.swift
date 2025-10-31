import MetalKit

class CanvasView: MTKView {
    init() {
        super.init(frame: .zero, device: GPU.device)
        delegate = self
        clearColor = .init(red: 0.6, green: 100, blue: 0, alpha: 1)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension CanvasView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(size)
    }

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let currentRenderPassDescriptor = view.currentRenderPassDescriptor
        else { return }
        let commandBuffer = GPU.commandQueue.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
