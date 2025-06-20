import TCanvas
import UIKit

class BrushCreatorViewController: UIViewController {
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.init(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(onCloseButtonTap), for: .touchUpInside)
        return button
    }()
    
    private let canvasContainerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true
        return container
    }()
    
    private var canvas: TCanvas?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .init(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
    }
    
    override func viewDidLayoutSubviews() {
        setupCanvas()
    }
    
    private func setupSubviews() {
        addCloseButton()
        addCanvasContainer()
    }
    
    private func addCloseButton() {
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor
                .constraint(equalTo: closeButton.widthAnchor, multiplier: 1),
            closeButton.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -30),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)
        ])
    }
    
    private func addCanvasContainer() {
        view.addSubview(canvasContainerView)
        
        NSLayoutConstraint.activate([
            canvasContainerView.topAnchor
                .constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            canvasContainerView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -30),
            canvasContainerView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 30),
            canvasContainerView.heightAnchor
                .constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
    }
    
    private func setupCanvas() {
        guard canvas == nil else { return }
        canvas = TCanvas(config: .init(isTransformEnabled: false, brush: .normal))
        canvas?.load(in: canvasContainerView)
    }
}


private extension BrushCreatorViewController {
    @objc
    func onCloseButtonTap() {
        dismiss(animated: true)
    }
}
