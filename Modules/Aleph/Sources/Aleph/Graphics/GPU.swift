import Metal

struct GPU {
    static var device: MTLDevice {
        let device = MTLCreateSystemDefaultDevice()
        assert(device != nil, "GPU not available")
        return device!
    }
    
    static let commandQueue = GPU.device.makeCommandQueue()!
}
