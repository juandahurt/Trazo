import Tartarus

enum Action {
    enum Transform {
        case translate(dx: Float, dy: Float)
        case rotate(Point, Float)
        case scale(Point, Float)
    }
    
    enum Layer {
        case fill(Int, Color)
        case merge(Rect)
    }
    
    case transform(Transform)
    case layer(Layer)
    case stroke(Touch)
}
