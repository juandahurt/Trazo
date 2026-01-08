import UIKit

/// Drawing engine! :)
public class Aleph {
    public static let debugShapeTextures: [TextureID] = {
        var ids: [TextureID] = []
        var count = 0
        while let id = TextureManager.loadTexture(
            fromFile: "shape-\(count)",
            withExtension: "png"
        ) {
            count += 1
            ids.append(id)
        }
        return ids
    }()
    
    public static let debugGranularityTextures: [TextureID] = {
        var ids: [TextureID] = []
        var count = 0
        while let id = TextureManager.loadTexture(
            fromFile: "gran-\(count)",
            withExtension: "png"
        ) {
            count += 1
            ids.append(id)
        }
        return ids
    }()
    
    public static func load() {
        PipelinesManager.load()
    }
    
    public static func makeCanvas(in viewController: UIViewController) -> CanvasViewController {
        let canvasViewController = CanvasViewController(
            canvasSize: viewController.view.frame
        )
        viewController.addChild(canvasViewController)
        viewController.view.addSubview(canvasViewController.view)
        canvasViewController.view.constrainEdges(to: viewController.view)
        return canvasViewController
    }
}
