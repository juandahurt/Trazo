import UIKit

public extension Aleph {
    func addCanvas(in view: UIView) {
        let canvas = CanvasView()
        view.addSubview(canvas)
        
        canvas.constrainEdges(to: view)
    }
}
