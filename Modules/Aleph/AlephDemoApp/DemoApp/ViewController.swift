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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Aleph.load()
        canvasViewController = Aleph.makeCanvas(in: self)
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var spacing: Float
    @Binding var pointSize: Float
    @Binding var opacity: Float
    
    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }
    
    func updateUIViewController(
        _ viewController: ViewController,
        context: Context
    ) {
        viewController.canvasViewController?.setSpacing(spacing)
        viewController.canvasViewController?.setPointSize(pointSize)
        viewController.canvasViewController?.setOpacity(opacity)
    }
}
