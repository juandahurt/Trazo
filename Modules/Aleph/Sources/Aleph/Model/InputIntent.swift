enum TransformIntent {
    case start, update
}

enum InputIntent {
    case transform(TransformIntent, [Int: [Touch]])
    case unknown
}
