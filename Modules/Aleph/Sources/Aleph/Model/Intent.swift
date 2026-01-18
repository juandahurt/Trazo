import Tartarus

enum Intent {
    enum Transform {
        case translation(x: Float, y: Float)
        case zoom(anchor: Point, scale: Float)
        case rotation(anchor: Point, angle: Float)
    }

    enum Layer {
        case invalidate
        case merge
        case fill(Color, Int)
        // case clear
    }
    
    enum LifeCycle {
        case load
    }
    
    case transform(Transform)
    case layer(Layer)
    case draw(Touch)
}
