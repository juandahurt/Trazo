import Aleph
import Combine
import UIKit

class ViewController: UIViewController {
    private var alephViewController:    CanvasViewController!
    private var shapeTextures:          [TextureID] = []
    private var granularityTextures:    [TextureID] = []
    
    private var currentBrush:           Brush!
    
    private var sidebarView:            SidebarView!
    
    public override var prefersStatusBarHidden: Bool {
        true
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        alephViewController = Aleph.makeCanvas(in: self)
        shapeTextures = Aleph.debugShapeTextures
        granularityTextures = Aleph.debugGranularityTextures
        
        addSidebar()
        
        currentBrush = .init(
            shapeTextureID: shapeTextures[3],
            granularityTextureID: granularityTextures[1],
            spacing: 5,
            pointSize: Float(sidebarView.sizeSlider.value),
            opacity: Float(sidebarView.opacitySlider.value),
            blendMode: .lighten
        )
        alephViewController.setBrush(currentBrush)
    }
    
    func addSidebar() {
        sidebarView = SidebarView()
        
        sidebarView.onSizeValueChange = { [weak self] in
            guard let self else { return }
            currentBrush.pointSize = Float($0)
            alephViewController.setBrush(currentBrush)
        }
        sidebarView.onOpacityValueChange = { [weak self] in
            guard let self else { return }
            currentBrush.opacity = Float($0)
            alephViewController.setBrush(currentBrush)
        }
        
        
        view.addSubview(sidebarView)
        
        NSLayoutConstraint.activate([
            sidebarView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sidebarView.widthAnchor.constraint(equalToConstant: 56),
            sidebarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            sidebarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1)
        ])
    }
}
