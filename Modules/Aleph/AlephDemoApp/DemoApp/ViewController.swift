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
    
    func setSpacing(_ value: Float) {
        canvasViewController?.setSpacing(value)
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var spcaing: Float
    
    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }
    
    func updateUIViewController(
        _ viewController: ViewController,
        context: Context
    ) {
        viewController.setSpacing(spcaing)
    }
}
