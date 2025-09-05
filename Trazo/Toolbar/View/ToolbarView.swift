import UIKit

class ToolbarView: UIView {
    private let mainStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let toolsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
//        stack.distribution = .fill
//        stack.backgroundColor = .red
        stack.spacing = 27
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0.8
        )
        addBlur()
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        setupMainStackView()
        
        let spacerLeft = UIView()
        spacerLeft.translatesAutoresizingMaskIntoConstraints = false
        spacerLeft.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerLeft.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        mainStackView.addArrangedSubview(spacerLeft)
        setupToolsStackView()
        
        let spacerRight = UIView()
        spacerRight.translatesAutoresizingMaskIntoConstraints = false
        spacerRight.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerRight.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        mainStackView.addArrangedSubview(spacerRight)
        
        NSLayoutConstraint.activate([
            spacerLeft.widthAnchor
                .constraint(equalTo: spacerRight.widthAnchor, multiplier: 1)
        ])
    }
    
    private func setupToolsStackView() {
        let brushButton = UIButton(configuration: .borderless())
        brushButton.configuration?.image = UIImage(systemName: "paintbrush.pointed.fill")
        brushButton.configuration?.baseForegroundColor = .white
        brushButton.configuration?.contentInsets = .zero
        brushButton.configuration?.imagePadding = .zero
        toolsStackView.addArrangedSubview(brushButton)
        
        let eraserButton = UIButton(configuration: .plain())
        eraserButton.configuration?.image = UIImage(systemName: "eraser.fill")
        eraserButton.configuration?.baseForegroundColor = .white
        eraserButton.configuration?.contentInsets = .zero
        eraserButton.configuration?.imagePadding = .zero
        eraserButton.layer.opacity = 0.3
        toolsStackView.addArrangedSubview(eraserButton)
        
        mainStackView.addArrangedSubview(toolsStackView)
        
        var constraints = toolsStackView.arrangedSubviews.map {
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        }
        
        constraints.append(contentsOf: [
            mainStackView.topAnchor.constraint(equalTo: toolsStackView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: toolsStackView.bottomAnchor),
        ])
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupMainStackView() {
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: mainStackView.topAnchor, constant: -4),
            leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 4)
        ])
    }
}
