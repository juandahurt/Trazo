import Tartarus

struct TransformData {
    let startPointA: Point
    let startPointB: Point
    let currPointA: Point
    let currPointB: Point
}

enum GesturePhase {
    case began, update, ended
}

enum InputIntent {
    case transform(GesturePhase, TransformData?)
}

enum Intent {
    case input(InputIntent)
}
