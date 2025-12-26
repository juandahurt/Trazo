import Metal

class PipelinesManager {
    enum ComputeType: String, CaseIterable {
        case fill = "fill_color"
        case colorize = "colorize"
        case merge = "merge"
    }
    
    enum RenderType: CaseIterable {
        case drawTexture
        case drawGrayscalePoints
        
        var label: String {
            switch self {
            case .drawTexture: "draw_texture"
            case .drawGrayscalePoints: "draw_grayscale_points"
            }
        }
        var vertexFunction: String {
            switch self {
            case .drawTexture: "draw_texture_vert"
            case .drawGrayscalePoints: "grayscale_point_vert"
            }
        }
        var fragmentFunction: String {
            switch self {
            case .drawTexture: "draw_texture_frag"
            case .drawGrayscalePoints: "grayscale_point_frag"
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
                return
            }
            guard
                let state = try? GPU.device.makeComputePipelineState(function: function)
            else {
                assert(
                    false,
                    "compute pipeline state \(type.rawValue) could not be created."
                )
                return
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
            if type == .drawGrayscalePoints {
                let vertexDesc = MTLVertexDescriptor()
                let vertexDescriptor = MTLVertexDescriptor()
                vertexDescriptor.attributes[0].format = .float2
                
                vertexDescriptor.attributes[1].format = .float
                vertexDescriptor
                    .attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
                
                vertexDescriptor.attributes[2].format = .float
                vertexDescriptor
                    .attributes[2].offset = MemoryLayout<SIMD2<Float>>.stride + MemoryLayout<Float>.stride
                
                vertexDescriptor
                    .layouts[0]
                    .stride = MemoryLayout<DrawablePoint>.stride
                
                descriptor.vertexDescriptor = vertexDescriptor
                descriptor.colorAttachments[0].isBlendingEnabled = true
                descriptor.colorAttachments[0].rgbBlendOperation = .add
                descriptor.colorAttachments[0].alphaBlendOperation = .add
                descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
                descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            }
            do {
                let state = try GPU.device.makeRenderPipelineState(
                    descriptor: descriptor
                )
                renderPipelines[type] = state
            } catch {
                assert(false, "render pipeline \(type.label) could not be created.")
            }
        }
    }
    
    static func computePipeline(for type: ComputeType) -> MTLComputePipelineState? {
        computePipelines[type]
    }
    
    static func renderPipeline(for type: RenderType) -> MTLRenderPipelineState? {
        renderPipelines[type]
    }
}
