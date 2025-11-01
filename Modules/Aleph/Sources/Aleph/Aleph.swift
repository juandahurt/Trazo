import UIKit

/// Drawing engine! :)
public class Aleph { 
    public static func load() {
        PipelinesManager.load()
       // TODO: load textures
    }
    
    public static func makeCanvas(in viewController: UIViewController) {
        let canvasViewController = CanvasViewController(
            canvasSize: viewController.view.frame
        )
        viewController.addChild(canvasViewController)
        viewController.view.addSubview(canvasViewController.view)
        canvasViewController.view.constrainEdges(to: viewController.view)
    }
}
