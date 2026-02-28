import Foundation

class StrokeProcessor {
    let queue = DispatchQueue(label: "aleph.stroke_queue", qos: .userInteractive)
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    func push(_ touch: Touch) {
        queue.async { [weak self] in
            guard let self else { return }
            print("inside stroke queue", "main thread", Thread.isMainThread)
            StrokeCommand(touch: touch).execute(context: context)
        }
    }
}
