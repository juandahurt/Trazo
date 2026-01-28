import Metal

class PipelinesManager {
    enum PipelineType {
        case present
//        case stroke(BlendMode)
        
        var vertexFunctionName: String {
            switch self {
            case .present: "present_vert"
            }
        }
        
        var fragmentFunctionName: String {
            switch self {
            case .present: "present_frag"
            }
        }
        
        var blendMode: BlendMode {
            switch self {
            case .present: .none
            }
        }
    }
    
    nonisolated(unsafe)
    static var cache: [PipelineType: MTLRenderPipelineState] = [:]
    
//    enum ComputeType: String, CaseIterable {
//        case fill = "fill_color"
//        case merge = "merge"
//    }
    
//    enum RenderType: CaseIterable {
//        case present
//        case drawGrayscalePoints
//        
//        var label: String {
//            switch self {
//            case .present: "present"
//            case .drawGrayscalePoints: "draw_grayscale_points"
//            }
//        }
//        var vertexFunction: String {
//            switch self {
//            case .present: "present_vert"
//            case .drawGrayscalePoints: "grayscale_point_vert"
//            }
//        }
//        var fragmentFunction: String {
//            switch self {
//            case .present: "present_frag"
//            case .drawGrayscalePoints: "grayscale_point_frag"
//            }
//        }
//    }
    
//    nonisolated(unsafe)
//    static var computePipelines: [ComputeType: MTLComputePipelineState] = [:]
//    
//    nonisolated(unsafe)
//    static var renderPipelines: [RenderType: MTLRenderPipelineState] = [:]
    
    static func load() {}
    
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
