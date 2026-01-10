enum InputIntent {
    case startTransform([Int: [Touch]])
    case transform([Int: [Touch]])
    case unknown
}
