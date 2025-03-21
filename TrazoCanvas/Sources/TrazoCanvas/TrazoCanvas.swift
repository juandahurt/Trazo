import UIKit
import simd

typealias Vector2 = simd_float2

public struct TrazoCanvas {
    var currentEnvironment: CanvasEnvironment?
    
    public init() {}
    
    @MainActor
    mutating public func makeCanvas() -> UIView {
        let canvasController = CanvasController()
        let canvasView = CanvasView(fingerGestureDelegate: canvasController)
        canvasController.canvasView = canvasView
        currentEnvironment = .init(
            canvasView: canvasView,
            canvasController: canvasController
        )
        return canvasView
    }
}

struct CanvasEnvironment {
    let canvasView: CanvasView
    let canvasController: CanvasController
}
