import MetalKit

class Engine: NSObject {
    let inputSystem = InputSystem()
    let intentSystem = IntentSystem()
    let transformSystem = TransformSystem()
    
    var context = SceneContext()
    
    func tick(in view: MTKView) {
        print("begin frame")
        // 1. resolve intents
        let pendingInput = inputSystem.drain()
        let intents = intentSystem.resolve(pendingInput)
        // 2. update
        for intent in intents {
            switch intent {
            case .transform(let transformIntent, let touchMap):
                switch transformIntent {
                case .start:
                    transformSystem.reset(touchMap: touchMap)
                case .update:
                    transformSystem.update(ctx: &context, touchMap: touchMap)
                }
            case .unknown:
                print("unknown")
            }
        }
        // 3. build render plan
        // 4. excecute plan
        print("end frame")
    }
}

extension Engine: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: implement
    }
    
    func draw(in view: MTKView) {
        tick(in: view)
    }
}
