//
//  PipelineManager.swift
//  Trazo
//
//  Created by Juan Hurtado on 24/01/25.
//

import MetalKit

class PipelineManager {
    private(set) var fillColorPipeline: MTLComputePipelineState!
    
    init() {
        loadPipelines()
    }
    
    private func loadPipelines() {
        fillColorPipeline = makeComputePipelineState(usingFunctionNamed: "fill_color")
    }
}

extension PipelineManager {
    func makeComputePipelineState(
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
