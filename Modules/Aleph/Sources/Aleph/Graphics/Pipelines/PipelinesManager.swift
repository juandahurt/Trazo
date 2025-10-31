import Metal

class PipelinesManager {
    enum ComputeType: String, CaseIterable {
        case fill = "fill_color"
    }
    
    nonisolated(unsafe)
    static var computePipelines: [ComputeType: MTLComputePipelineState] = [:]
    
    static func load() {
        for type in ComputeType.allCases {
            guard let function = GPU.library.makeFunction(name: type.rawValue) else {
                assert(false, "function \(type.rawValue) not found.")
            }
            guard
                let state = try? GPU.device.makeComputePipelineState(function: function)
            else {
                assert(
                    false,
                    "compute pipeline state \(type.rawValue) could not be created."
                )
            }
        }
    }
    
    static func computePipeLine(for type: ComputeType) -> MTLComputePipelineState? {
        computePipelines[type]
    }
}
