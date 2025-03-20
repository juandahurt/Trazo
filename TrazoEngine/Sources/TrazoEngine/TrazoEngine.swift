
import MetalKit



struct CanvasState {
    
}

public struct TrazoEngine {
    public init() {}
    
    @MainActor
    public func makeCanvas() -> UIView {
        CanvasView(frame: .zero)
    }
}
