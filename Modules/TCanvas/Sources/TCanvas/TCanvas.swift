import UIKit

@MainActor
public class TCanvas {
    let canvasView: TCCanvasView
    let viewModel: TCViewModel
    
    public init(config: TCConfig) {
        viewModel = .init(config: config)
        canvasView = .init(viewModel: viewModel)
    }
    
    public func load(in view: UIView) {
        canvasView.load(in: view)
    }
    
    public func updateBrush(with brush: TCBrush) {
        viewModel.updateBrush(with: brush)
    }
    
    public func setTool(_ toolType: TCToolType) {
        viewModel.updateToolType(toolType)
    }
}
