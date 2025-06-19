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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .init(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        addCloseButton()
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
}


private extension BrushCreatorViewController {
    @objc
    func onCloseButtonTap() {
        dismiss(animated: true)
    }
}
