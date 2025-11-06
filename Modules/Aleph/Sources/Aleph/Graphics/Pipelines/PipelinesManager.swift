import Metal

class PipelinesManager {
    enum ComputeType: String, CaseIterable {
        case fill = "fill_color"
    }
    
    enum RenderType: CaseIterable {
        case drawTexture
        
        var label: String {
            switch self {
            case .drawTexture: "draw_texture"
            }
        }
        var vertexFunction: String {
            switch self {
            case .drawTexture: "draw_texture_vert"
            }
        }
        var fragmentFunction: String {
            switch self {
            case .drawTexture: "draw_texture_frag"
            }
        }
    }
    
    nonisolated(unsafe)
    static var computePipelines: [ComputeType: MTLComputePipelineState] = [:]
    
    nonisolated(unsafe)
    static var renderPipelines: [RenderType: MTLRenderPipelineState] = [:]
    
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
            computePipelines[type] = state
        }
        
        for type in RenderType.allCases {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
            descriptor.vertexFunction = GPU.library
                .makeFunction(name: type.vertexFunction)
            descriptor.fragmentFunction = GPU.library
                .makeFunction(name: type.fragmentFunction)
            guard
                let state = try? GPU.device.makeRenderPipelineState(
                    descriptor: descriptor
                )
            else {
                assert(false, "render pipeline \(type.label) could not be created.")
            }
            renderPipelines[type] = state
        }
    }
    
    static func computePipeline(for type: ComputeType) -> MTLComputePipelineState? {
        computePipelines[type]
    }
    
    static func renderPipeline(for type: RenderType) -> MTLRenderPipelineState? {
        renderPipelines[type]
    }
}
