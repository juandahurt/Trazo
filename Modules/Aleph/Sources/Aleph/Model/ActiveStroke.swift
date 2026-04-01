import Tartarus

class ActiveStroke {
    private let maxNumberTouches:   Int = 4
    private(set) var touches:       [Touch] = []
    var offset:                     Float = 0
    var accDist:                    Float = 0
    var accArea:                    Rect?
    
    func add(touch: Touch) {
        if touches.count == maxNumberTouches {
            touches.removeFirst()
        }
        touches.append(touch)
    }
    
    func addArea(_ area: Rect) {
        if let accArea {
            self.accArea = accArea.union(area)
        } else {
            accArea = area
        }
    }
}
