//
//  PipelineManager.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit

class PipelineManager {
    private(set) var fillColorPipeline: MTLComputePipelineState!
    private(set) var drawTexturePipeline: MTLRenderPipelineState!
    
    init() {
        loadPipelines()
    }
    
    private func loadPipelines() {
        fillColorPipeline = _makeComputePipelineState(usingFunctionNamed: "fill_color")
        drawTexturePipeline = _makeRenderPipelieState(
            withLabel: "Draw Texture",
            vertexFunction: "draw_texture_vert",
            fragmentFunction: "draw_texture_frag"
        ) { descriptor in
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
        }
    }
}

extension PipelineManager {
    private func _makeRenderPipelieState(
        withLabel label: String,
        vertexFunction: String,
        fragmentFunction: String,
        factory: (MTLRenderPipelineDescriptor) -> Void
    ) -> MTLRenderPipelineState {
        let library = Metal.defaultLibrary
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: vertexFunction)
        descriptor.fragmentFunction = library.makeFunction(name: fragmentFunction)
        descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        descriptor.label = label
        
        factory(descriptor)
        
        do {
            return try Metal.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
    
    private func _makeComputePipelineState(
        usingFunctionNamed functionName: String
    ) -> MTLComputePipelineState {
        let library = Metal.defaultLibrary
        guard let function = library.makeFunction(name: functionName) else {
            fatalError("Function \(functionName) not found in library.")
        }
        do {
            return try Metal.device.makeComputePipelineState(function: function)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
}
