import Tartarus
import UIKit

class SliderView: UIControl {
    let thickness:      CGFloat = 6
    let cornerRadius:   CGFloat = 3
    var trackLayer:     CAShapeLayer
    var valueLayer:     CAShapeLayer
    var t:              CGFloat
    
    let minValue:       CGFloat
    let maxValue:       CGFloat
    var value:          CGFloat
    
    var didSetupLayers: Bool = false
    var isEditing:      Bool = false
    
    init(minValue: CGFloat, maxValue: CGFloat, value: CGFloat) {
        trackLayer = CAShapeLayer()
        trackLayer.cornerRadius = cornerRadius
        trackLayer.backgroundColor = .init(
            red: 0.47,
            green: 0.47,
            blue: 0.47,
            alpha: 0.2
        )
        
        valueLayer = CAShapeLayer()
        valueLayer.cornerRadius = cornerRadius
        valueLayer.backgroundColor = .init(
            red: 0,
            green: 0.53,
            blue: 1,
            alpha: 1
        )
        
        self.minValue = minValue
        self.maxValue = maxValue
        self.value = value
        
        t = 0
        
        super.init(frame: .zero)
        setup()
    }
    
    private var currentThickness: CGFloat {
        isEditing ? thickness * 2 : thickness
    }
    
    private var currentCornerRadius: CGFloat {
        isEditing ? cornerRadius * 2 : cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("?")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !didSetupLayers else { return }
        
        layoutTrackLayer()
        layoutValueLayer()
        addSublayers()
        
        didSetupLayers = true
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        setupT()
    }
    
    private func addSublayers() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(valueLayer)
    }
    
    private func setupT() {
        t = (value - minValue) / (maxValue - minValue)
    }
    
    private func layoutTrackLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0.2)
        trackLayer.anchorPoint = .init(x: 0.5, y: 1)
        trackLayer.bounds = .init(
            x: 0,
            y: 0,
            width: currentThickness,
            height: bounds.height
        )
        trackLayer.cornerRadius = currentCornerRadius
        trackLayer.position = .init(x: bounds.midX, y: bounds.maxY)
        CATransaction.commit()
    }
    
    private func layoutValueLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0.2)
        valueLayer.anchorPoint = .init(x: 0.5, y: 1)
        valueLayer.bounds = .init(
            x: 0,
            y: 0,
            width: currentThickness,
            height: t * bounds.height
        )
        valueLayer.cornerRadius = currentCornerRadius
        valueLayer.position = .init(x: bounds.midX, y: bounds.maxY)
        CATransaction.commit()
    }
}

// MARK: Value update
extension SliderView {
    func updateValue(usingLocation location: CGPoint) {
        t = min(1, max(0, 1 - (location.y / bounds.height)))
        value = lerp(t: t, v0: minValue, v1: maxValue)
        
        sendActions(for: .valueChanged)
    }
}

// MARK: Touches
extension SliderView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        isEditing = true
        updateValue(usingLocation: location)
        layoutTrackLayer()
        layoutValueLayer()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        updateValue(usingLocation: location)
        layoutValueLayer()
        layoutTrackLayer()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isEditing = false
        layoutTrackLayer()
        layoutValueLayer()
    }
}
