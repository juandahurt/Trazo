//
//  PipelinesStore.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit
import TrazoCore

@MainActor
final class PipelinesStore {
    private(set) var fillColorPipeline: MTLComputePipelineState!
    private(set) var drawTexturePipeline: MTLRenderPipelineState!
    private(set) var drawGrayScalePointPipeline: MTLRenderPipelineState!
    private(set) var colorizePipeline: MTLComputePipelineState!
    private(set) var mergePipeline: MTLComputePipelineState!
    private(set) var removePointsPipeline: MTLComputePipelineState!
    
    static let instance = PipelinesStore()
    
    private init() {
        _loadPipelines()
    }
    
    private func _loadPipelines() {
        fillColorPipeline = _makeComputePipelineState(usingFunctionNamed: "fill_color")
        drawTexturePipeline = _makeRenderPipelieState(
            withLabel: "Draw Texture",
            vertexFunction: "draw_texture_vert",
            fragmentFunction: "draw_texture_frag"
        ) { descriptor in
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        }
        drawGrayScalePointPipeline = _makeRenderPipelieState(
            withLabel: "Draw Gray Scale Point",
            vertexFunction: "gray_scale_point_vert",
            fragmentFunction: "gray_scale_point_frag"
        ) { descriptor in
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
            vertexDescriptor.attributes[1].offset = MemoryLayout<Vector2>.stride
            
            vertexDescriptor
                .layouts[0]
                .stride = MemoryLayout<DrawablePoint>.stride
            
            descriptor.vertexDescriptor = vertexDescriptor
        }
        colorizePipeline = _makeComputePipelineState(usingFunctionNamed: "colorize")
        mergePipeline = _makeComputePipelineState(usingFunctionNamed: "merge_textures")
        removePointsPipeline = _makeComputePipelineState(usingFunctionNamed: "substract")
    }
}

extension PipelinesStore {
    private func _makeRenderPipelieState(
        withLabel label: String,
        vertexFunction: String,
        fragmentFunction: String,
        factory: (MTLRenderPipelineDescriptor) -> Void
    ) -> MTLRenderPipelineState {
        let library = GPU.defaultLibrary
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: vertexFunction)
        descriptor.fragmentFunction = library.makeFunction(name: fragmentFunction)
        descriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        descriptor.label = label
        
        factory(descriptor)
        
        do {
            return try GPU.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
    
    private func _makeComputePipelineState(
        usingFunctionNamed functionName: String
    ) -> MTLComputePipelineState {
        let library = GPU.defaultLibrary
        guard let function = library.makeFunction(name: functionName) else {
            fatalError("Function \(functionName) not found in library.")
        }
        do {
            return try GPU.device.makeComputePipelineState(function: function)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
}
