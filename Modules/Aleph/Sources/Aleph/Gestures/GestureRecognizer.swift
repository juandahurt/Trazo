protocol GestureRecognizer {
    func recognize(from touchMap: [Int: [Touch]]) -> InputIntent?
}
