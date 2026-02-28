import Foundation

class StrokeProcessor {
    let queue = DispatchQueue(label: "aleph.stroke_queue", qos: .userInteractive)
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    func push(_ touch: Touch) {
        let context = context
        queue.async {
            StrokeCommand(touch: touch).execute(context: context)
        }
    }
}
