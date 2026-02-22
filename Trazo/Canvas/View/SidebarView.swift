import UIKit

class SidebarView: UIView {
    let cornerRadius:       CGFloat = 12
    let verticalPadding:    CGFloat = 16
    let spaceBetween:       CGFloat = 22
    
    var sizeSlider:         SliderView!
    var opacitySlider:      SliderView!
   
    var onSizeValueChange: ((CGFloat) -> Void)?
    var onOpacityValueChange: ((CGFloat) -> Void)?
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("??")
    }
}

private extension SidebarView {
    func setup() {
        backgroundColor = .init(
            red: 0.109,
            green: 0.109,
            blue: 0.117,
            alpha: 1
        )
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = .init(
            red: 0.254,
            green: 0.231,
            blue: 0.231,
            alpha: 1
        )
        
        addSizeSlider()
        addOpacitySlider()
    }
    
    func addSizeSlider() {
        sizeSlider = SliderView(
            minValue: 8,
            maxValue: 40,
            value: 10
        )
        sizeSlider
            .addTarget(self, action: #selector(onSizeChange), for: .valueChanged)
        addSubview(sizeSlider)
        
        NSLayoutConstraint.activate([
            sizeSlider.topAnchor
                .constraint(equalTo: topAnchor, constant: verticalPadding),
            sizeSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            sizeSlider.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func addOpacitySlider() {
        opacitySlider = SliderView(minValue: 0, maxValue: 1, value: 0.4)
        opacitySlider.addTarget(self, action: #selector(onOpacityChange), for: .valueChanged)
        addSubview(opacitySlider)
        
        NSLayoutConstraint.activate([
            opacitySlider.heightAnchor.constraint(equalTo: sizeSlider.heightAnchor),
            opacitySlider.bottomAnchor
                .constraint(equalTo: bottomAnchor, constant: -verticalPadding),
            opacitySlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            opacitySlider.trailingAnchor.constraint(equalTo: trailingAnchor),
            opacitySlider.topAnchor
                .constraint(equalTo: sizeSlider.bottomAnchor, constant: spaceBetween)
        ])
    }
}

extension SidebarView {
    @objc
    private func onSizeChange() {
        onSizeValueChange?(sizeSlider.value)
    }
    
    @objc
    private func onOpacityChange() {
        onOpacityValueChange?(opacitySlider.value)
    }
}
