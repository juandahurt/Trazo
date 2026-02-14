import Aleph
import SwiftUI
import UIKit

class ViewController: UIViewController {
    weak var canvasViewController: CanvasViewController?
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        Aleph.load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasViewController = Aleph.makeCanvas(in: self)
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var spacing: Float
    @Binding var pointSize: Float
    @Binding var opacity: Float
    @Binding var selectedShapeTexture: TextureID
    @Binding var selectedGranularityTexture: TextureID
    
    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }
    
    func updateUIViewController(
        _ viewController: ViewController,
        context: Context
    ) {
        let brush = Brush(
            shapeTextureID: selectedShapeTexture,
            granularityTextureID: selectedGranularityTexture,
            spacing: spacing,
            pointSize: pointSize,
            opacity: opacity
        )
        viewController.canvasViewController?.setBrush(brush)
    }
}
