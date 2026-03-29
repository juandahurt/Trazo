class ActiveStroke {
    private let maxNumberTouches:   Int = 4
    private(set) var touches:       [Touch] = []
    var offset:                     Float = 0
    var accDist:                    Float = 0
    
    func add(touch: Touch) {
        if touches.count == maxNumberTouches {
            touches.removeFirst()
        }
        touches.append(touch)
    }
}
