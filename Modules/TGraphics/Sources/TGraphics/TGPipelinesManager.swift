import Foundation
import Metal
import simd

class TGPipelinesManager {
    enum TGComputePipelineType: String, CaseIterable {
        case fill = "fill_color"
        case merge = "merge_textures"
    }
    enum TGRenderPipelineType: CaseIterable {
        case drawTexture
        case drawGrayScalePoints
        
        var label: String {
            switch self {
            case .drawTexture: "draw_texture"
            case .drawGrayScalePoints: "draw_gray_scale_points"
            }
        }
        var vertexFunction: String {
            switch self {
            case .drawTexture: "draw_texture_vert"
            case .drawGrayScalePoints: "gray_scale_point_vert"
            }
        }
        var fragmentFunction: String {
            switch self {
            case .drawTexture: "draw_texture_frag"
            case .drawGrayScalePoints: "gray_scale_point_frag"
            }
        }
    }
    
    var computePipelineStates = Array<MTLComputePipelineState?>(
        repeating: nil,
        count: TGComputePipelineType.allCases.count
    )
    var renderPipelineStates = Array<MTLRenderPipelineState?>(
        repeating: nil,
        count: TGRenderPipelineType.allCases.count
    )
    private let dispatchGroup = DispatchGroup()
    
    func load() {
        for index in TGComputePipelineType.allCases.indices {
            dispatchGroup.enter()
            makeComputePipelineState(
                usingFunctionNamed: TGComputePipelineType.allCases[index].rawValue
            ) { [weak self] in
                guard let self else { return }
                self.computePipelineStates[index] = $0
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
       
        // TODO: load as compute pipelines
        renderPipelineStates[0] = makeRenderPipelieState(
            withLabel: TGRenderPipelineType.drawTexture.label,
            vertexFunction: TGRenderPipelineType.drawTexture.vertexFunction,
            fragmentFunction: TGRenderPipelineType.drawTexture.fragmentFunction,
            factory: { descriptor in
                descriptor.colorAttachments[0].isBlendingEnabled = true
                descriptor.colorAttachments[0].rgbBlendOperation = .add
                descriptor.colorAttachments[0].alphaBlendOperation = .add
                descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
                descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            }
        )
        renderPipelineStates[1] = makeRenderPipelieState(
            withLabel: TGRenderPipelineType.drawGrayScalePoints.label,
            vertexFunction: TGRenderPipelineType.drawGrayScalePoints.vertexFunction,
            fragmentFunction: TGRenderPipelineType.drawGrayScalePoints.fragmentFunction,
            factory: { descriptor in
                descriptor.colorAttachments[0].isBlendingEnabled = true
                descriptor.colorAttachments[0].rgbBlendOperation = .max
                descriptor.colorAttachments[0].alphaBlendOperation = .max
                descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
                descriptor.colorAttachments[0].destinationRGBBlendFactor = .one
                descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
                descriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
                
                let vertexDescriptor = MTLVertexDescriptor()
                vertexDescriptor.attributes[0].format = .float2
                
                vertexDescriptor.attributes[1].format = .float
                vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float2>.stride
                
                vertexDescriptor
                    .layouts[0]
                    .stride = MemoryLayout<TGRenderablePoint>.stride
                
                descriptor.vertexDescriptor = vertexDescriptor
            }
        )
    }
    
    func computePipeline(ofType type: TGComputePipelineType) -> MTLComputePipelineState? {
        guard let index = TGComputePipelineType.allCases.firstIndex(of: type) else {
            return nil
        }
        return computePipelineStates[index]
    }
    func renderPipeline(ofType type: TGRenderPipelineType) -> MTLRenderPipelineState? {
        guard let index = TGRenderPipelineType.allCases.firstIndex(of: type) else {
            return nil
        }
        return renderPipelineStates[index]
    }
    
    private func makeComputePipelineState(
        usingFunctionNamed functionName: String,
        completion: @escaping (MTLComputePipelineState) -> Void
    ) {
        let library = TGDevice.defaultLibrary
        guard let function = library.makeFunction(name: functionName) else {
            fatalError("Function \(functionName) not found in library.")
        }
        TGDevice.device.makeComputePipelineState(
            function: function
        ) { pipelineState, error in
            if let pipelineState {
                completion(pipelineState)
            } else {
                debugPrint(error!)
                fatalError()
            }
        }
    }
    
    private func makeRenderPipelieState(
        withLabel label: String,
        vertexFunction: String,
        fragmentFunction: String,
        factory: (MTLRenderPipelineDescriptor) -> Void
    ) -> MTLRenderPipelineState {
        let library = TGDevice.defaultLibrary
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: vertexFunction)
        descriptor.fragmentFunction = library.makeFunction(name: fragmentFunction)
        descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        descriptor.label = label
        
        factory(descriptor)
        
        do {
            return try TGDevice.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
}
