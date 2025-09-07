import Foundation
import Metal
import simd

class TGPipelinesManager: @unchecked Sendable {
    enum TGComputePipelineType: String, CaseIterable {
        case fill = "fill_color"
        case merge = "merge_textures"
        case colorize = "colorize"
        case substract = "subtract_texture"
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
    private let queue = DispatchQueue.global()
    
    func load() {
        for index in TGComputePipelineType.allCases.indices {
            queue.async(group: dispatchGroup) { [weak self] in
                guard let self else { return }
                makeComputePipelineState(
                    usingFunctionNamed: TGComputePipelineType.allCases[index].rawValue
                ) { [weak self] in
                    guard let self else { return }
                    computePipelineStates[index] = $0
                }
            }
        }
        dispatchGroup.wait()
        
        for (index, type) in TGRenderPipelineType.allCases.enumerated() {
            dispatchGroup.enter()
            TGRenderPipelineStateFactory()
                .makePipelineState(
                    ofType: type) { [weak self] in
                        guard let self else { return }
                        renderPipelineStates[index] = $0
                        dispatchGroup.leave()
                    }
        }
        dispatchGroup.enter()
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
}
