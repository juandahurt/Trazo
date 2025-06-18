import UIKit

@MainActor
public class TCanvas {
    let canvasView: TCCanvasView
    
    public init(config: TCConfig) {
        canvasView = TCCanvasView(config: config)
    }
    
    //    public var brushOpacity: Float {
    //        get {
    //            painter.brushOpacity
    //        }
    //        set {
    //            painter.brushOpacity = newValue
    //        }
    //    }
    //
    //    public var brushSize: Float {
    //        get {
    //            painter.brushSize
    //        }
    //        set {
    //            painter.brushSize = newValue
    //        }
    //    }
    
    public func load(in view: UIView) {
        canvasView.load(in: view)
    }
}
