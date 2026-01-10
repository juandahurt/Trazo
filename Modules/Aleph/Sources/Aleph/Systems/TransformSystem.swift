import Tartarus

class TransformSystem {
    var baseTransform = Transform.identity
    
    func reset(touchMap: [Int: [Touch]]) {
        guard touchMap.count == 2 else { return }
        print("reset transform")
    }
    
    func update(ctx: inout SceneContext, touchMap: [Int: [Touch]]) {
        guard touchMap.count == 2 else { return }
        print("updating in transform system")
    }
}

