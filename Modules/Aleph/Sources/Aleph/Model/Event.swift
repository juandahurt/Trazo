import Tartarus

enum Event {
    enum Input {
        case finger(Touch)
    }
    enum SceneLifeCycle {
        case load
    }

    enum Transform {
        case translate(x: Float, y: Float)
        case zoom(anchor: Point, scale: Float)
        case rotation(anchor: Point, angle: Float)
    }
    
    case touch(Input)
    case transform(Transform)
    case lifeCycle(SceneLifeCycle)
    case brush(Brush)
}
