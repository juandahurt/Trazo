import Caravaggio
import Metal

struct GPU {
    static var device: MTLDevice {
        let device = MTLCreateSystemDefaultDevice()
        assert(device != nil, "GPU not available")
        return device!
    }
    
    static let commandQueue = GPU.device.makeCommandQueue()!
    
    static let library: MTLLibrary = {
        let lib = try? device.makeDefaultLibrary(bundle: Caravaggio.module)
        assert(lib != nil, "couldn't create default library")
        return lib!
    }()
}
