import Metal

@MainActor
public struct TrazoEngine {
    static var commandBuffer: MTLCommandBuffer?
    
    static func makeCommandBuffer() {
        commandBuffer = GPU.commandQueue.makeCommandBuffer()
    }
    
    /// Loads the engine.
    public static func load() {
        makeCommandBuffer()
        // TODO: load pipeline states
    }
    
    public static func reset() {
        makeCommandBuffer()
    }
    
    /// Submits the commands to the GPU
    public static func commit() {
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }
}
