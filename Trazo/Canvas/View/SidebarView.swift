import UIKit

class SidebarView: UIView {
    let padding: CGFloat = 8
    
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
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        layer.cornerCurve = .continuous
        
        addSizeSlider()
    }
    
    func addSizeSlider() {
        let sizeSlider = SliderView(
            minValue: 8,
            maxValue: 40,
            value: 10
        )
        addSubview(sizeSlider)
        
        NSLayoutConstraint.activate([
            sizeSlider.centerYAnchor.constraint(equalTo: centerYAnchor),
            sizeSlider.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            sizeSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            sizeSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            sizeSlider.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
