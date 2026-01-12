import Tartarus

class TransformRecognizer: GestureRecognizer {
    private var initialA: Point?
    private var initialB: Point?
    private var isActive = false
    
    func recognize(from touchMap: [Int : [Touch]]) -> InputIntent? {
        guard touchMap.count == 2 else {
            if isActive {
                isActive = false
                reset()
                return .transform(.ended, nil)
            }
            return nil
        }
        let keys = touchMap.keys.sorted()
        guard let a = touchMap[keys[0]] else { return nil }
        guard let b = touchMap[keys[1]] else { return nil }
        guard let firstA = a.first else { return nil }
        guard let firstB = b.first else { return nil }
        guard let lastA = a.last else { return nil }
        guard let lastB = b.last else { return nil }
        
        if !isActive {
            isActive = true
            return .transform(
                .began,
                .init(
                    startPointA: firstA.location,
                    startPointB: firstB.location,
                    currPointA: lastA.location,
                    currPointB: lastB.location
                )
            )
        }
        
        return .transform(
            .update,
            .init(
                startPointA: firstA.location,
                startPointB: firstB.location,
                currPointA: lastA.location,
                currPointB: lastB.location
            )
        )
    }
    
    func reset() {
        initialA = nil
        initialB = nil
    }
}
