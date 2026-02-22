import Aleph
import Combine
import UIKit

class ViewController: UIViewController {
    private var brushItem: UIBarButtonItem!
    private var eraserItem: UIBarButtonItem!
    
    private var alephViewController: CanvasViewController!
    private var shapeTextures: [TextureID] = []
    private var granularityTextures: [TextureID] = []
    
    private var currentBrush: Brush!
    
    public override var prefersStatusBarHidden: Bool {
        true
    }

    public override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .all
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
        
        currentBrush = .init(
            shapeTextureID: shapeTextures[0],
            granularityTextureID: granularityTextures[0],
            spacing: 2,
            pointSize: 8,
            opacity: 1,
            blendMode: .lighten
        )
        alephViewController.setBrush(currentBrush)
        
        addSidebar()
    }
    
    func addSidebar() {
        let sidebarView = SidebarView()
        
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
