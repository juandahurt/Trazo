import Metal

enum PipelineType: Hashable {
    case present
    case stroke(BlendMode)
    case merge(BlendMode)
    
    var vertexFunctionName: String {
        switch self {
        case .present: "present_vert"
        case .stroke: "stroke_vert"
        case .merge: "merge_vert"
        }
    }
    
    var fragmentFunctionName: String {
        switch self {
        case .present: "present_frag"
        case .stroke: "stroke_frag"
        case .merge: "merge_frag"
        }
    }
    
    var blendMode: BlendMode {
        switch self {
        case .present: .none
        case .stroke(let blendMode): blendMode
        case .merge(let blendMode): blendMode
        }
    }
}


class PipelinesManager {
    nonisolated(unsafe)
    static var cache: [PipelineType: MTLRenderPipelineState] = [:]
    
    static func pipeline(for type: PipelineType) -> MTLRenderPipelineState? {
        if let pipelineState = cache[type] {
            return pipelineState
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        descriptor.colorAttachments[0].apply(mode: type.blendMode)
        
        let vertexFunction = GPU.library.makeFunction(name: type.vertexFunctionName)
        descriptor.vertexFunction = vertexFunction
        let fragmentFunction = GPU.library.makeFunction(name: type.fragmentFunctionName)
        descriptor.fragmentFunction = fragmentFunction
        
        do {
            let pipelineState = try GPU.device.makeRenderPipelineState(descriptor: descriptor)
            cache[type] = pipelineState
            return pipelineState
        } catch {
            debugPrint(error)
            return nil
        }
    }
}
