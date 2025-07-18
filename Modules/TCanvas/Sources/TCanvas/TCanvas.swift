import TPainter
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
    
    public func updateBrush(with brush: TPBrush) {
        viewModel.updateBrush(with: brush)
    }
    
    public func setTool(_ tool: TCTool) {
        viewModel.updateTool(tool)
    }
}
