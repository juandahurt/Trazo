extension Array {
    mutating func popFirst() -> Element? {
        if let first {
            self.removeFirst()
            return first
        }
        return nil
    }
}
