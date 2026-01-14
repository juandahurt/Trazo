import Tartarus

enum Intent {
    enum Transform {
        case translation(x: Float, y: Float)
        case zoom(anchor: Point, scale: Float)
    }
    enum Merge {
        case all
        case indices(Set<Int>)
    }

    enum Layer {
        case merge(Merge)
        // case clear
    }
    case transform(Transform)
    case layer(Layer)
}
