import Metal
import simd

class TGRenderPipelineStateFactory {
    func makePipelineState(
        ofType type: TGPipelinesManager.TGRenderPipelineType,
        completion: @escaping (MTLRenderPipelineState) -> Void
    ) {
        let descriptor = makeDescriptor(
            withLabel: type.label,
            vertexFunction: type.vertexFunction,
            fragmentFunction: type.fragmentFunction
        )
        
        switch type {
        case .drawTexture:
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        case .drawGrayScalePoints:
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
        
        TGDevice.device.makeRenderPipelineState(descriptor: descriptor) { pipelineState, error in
            if let pipelineState {
                completion(pipelineState)
            } else {
                debugPrint(error!)
                fatalError()
            }
        }
    }
    
    private func makeDescriptor(
        withLabel label: String,
        vertexFunction: String,
        fragmentFunction: String
    ) -> MTLRenderPipelineDescriptor {
        let library = TGDevice.defaultLibrary
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: vertexFunction)
        descriptor.fragmentFunction = library.makeFunction(name: fragmentFunction)
        descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        descriptor.label = label
        return descriptor
    }
}
