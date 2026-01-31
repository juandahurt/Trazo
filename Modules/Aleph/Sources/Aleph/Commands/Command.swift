import Tartarus

protocol Commandable {
    func execute(context: Context)
}

enum Command {
    enum Transform {
        case translate(dx: Float, dy: Float)
        case rotate(Point, Float)
        case scale(Point, Float)
    }
    
    enum Layer {
        case fill(TextureID, Color)
    }
    
    case transform(Transform)
    case layer(Layer)
    case stroke(Touch)
    
    var instance: Commandable {
        switch self {
        case .transform(let transform):
            switch transform {
            case .translate(let dx, let dy):
                TransformCommand(transform: .init(dx: dx, dy: dy))
            case .rotate(let anchor, let rotation):
                TransformCommand(transform: .init(anchor: anchor, rotation: rotation))
            case .scale(let anchor, let scale):
                TransformCommand(transform: .init(anchor: anchor, scale: scale))
            }
        case .layer(let layer):
            switch layer {
            case .fill(let texture, let color):
                FillCommand(color: color, texture: texture)
            }
        case .stroke(let touch):
            StrokeCommand(touch: touch)
        }
    }
}
