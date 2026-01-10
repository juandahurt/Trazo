class InputSystem {
    private var pendingInput: [[Touch]] = []
    
    func enqueue(_ touches: [Touch]) {
        pendingInput.append(touches)
    }
    
    func drain() -> [[Touch]] {
        defer { pendingInput = [] }
        return pendingInput
    }
}
