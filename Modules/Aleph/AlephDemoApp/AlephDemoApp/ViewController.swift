import Aleph
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Aleph.load()
        Aleph.makeCanvas(in: self)
    }
}

