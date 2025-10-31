import Aleph
import UIKit

class ViewController: UIViewController {
    let engine = Aleph()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine.addCanvas(in: view)
    }
}

