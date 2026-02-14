import Metal

class BufferAllocator {
    /// Big buffers to use. One per frame
    private var ringBuffers:    [MTLBuffer] = []
    /// Current buffer index
    private var currentIndex:   Int = 0
    /// Size of each buffer, 4MB by deafult
    private var bufferSize:     Int = 2 * 1024 * 1024 // 4MB
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
    
    func alloc<T>(_ data: [T]) -> (MTLBuffer, Int) {
        let stride = MemoryLayout<T>.stride
        let size = data.count * stride
        let alignment = 256
        let alignedOffset = alignOffset(currentOffset, to: alignment)
        guard alignedOffset + size <= bufferSize else {
            fatalError("out of bounds")
        }
        
        let buffer = ringBuffers[currentIndex]
        let pointer = buffer.contents()
            .advanced(by: alignedOffset)
            .assumingMemoryBound(to: T.self)
        for index in data.indices {
            pointer[index] = data[index]
        }
        
        currentOffset = alignedOffset + size
        
//        print("-------")
//        print("Allocating:", size)
//        print("Current index:", currentIndex)
//        print("Current offset:", currentOffset)
//        print("Usage: \(Float(currentOffset) / Float(bufferSize) * 100)%")
//        print("-------")
        
        return (buffer, alignedOffset)
    }
    
    private func alignOffset(_ offset: Int, to alignment: Int) -> Int {
        return (offset + alignment - 1) & ~(alignment - 1)
    }
}
