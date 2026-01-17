import Tartarus

enum Intent {
    enum Transform {
        case translation(x: Float, y: Float)
        case zoom(anchor: Point, scale: Float)
        case rotation(anchor: Point, angle: Float)
    }

    enum Layer {
        case merge
        case fill(Color, Int)
        // case clear
    }
    case transform(Transform)
    case layer(Layer)
    case draw(Touch)
}
