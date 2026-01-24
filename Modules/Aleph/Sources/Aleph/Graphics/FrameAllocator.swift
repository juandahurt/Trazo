import Metal

class FrameAllocator {
    /// Big buffers to use. One per frame
    private var ringBuffers:    [MTLBuffer] = []
    /// Current buffer index
    private var currentIndex:   Int = 0
    /// Size of each buffer, 4MB by deafult
    private var bufferSize:     Int = 4 * 1024 * 1024 // 4MB
    /// Offset in the current buffer
    private var currentOffset:  Int = 0
    /// Number of buffers
    private let bufferCount:    Int = 3
    
    init() {
        // triple buffering
        for _ in 0..<bufferCount {
            guard let buffer = GPU.device.makeBuffer(
                length: bufferSize,
                options: .storageModeShared
            ) else {
                return
            }
            ringBuffers.append(buffer)
        }
    }
    
    func newFrame() {
        currentIndex = (currentIndex + 1) % bufferCount
        currentOffset = 0
    }
}
