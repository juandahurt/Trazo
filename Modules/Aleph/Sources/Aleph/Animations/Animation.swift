class Animation {
    enum EasingType {
        case linear, easeIn, easeOut
    }
    
    let duration:       Float
    var elapsedTime:    Float = 0.0
    var isAlive:        Bool {
        elapsedTime < duration
    }
    let fromValue:      Any
    let toValue:        Any
    let easingType: EasingType
    
    init(fromValue: Any, toValue: Any, duration: Float, easingType: EasingType = .linear) {
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.easingType = easingType
    }
    
    func update(dt: Float, ctx: Context) {}
    
    final func ease(t: Float) -> Float {
        switch easingType {
        case .linear:
            t
        case .easeIn:
            t * t
        case .easeOut:
            1 - (1 - t) * (1 - t)
        }
    }
}
