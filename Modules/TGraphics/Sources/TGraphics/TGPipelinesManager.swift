import Metal
import Foundation

class TGPipelinesManager {
    enum TGComputePipelineType: String, CaseIterable {
        case fill = "fill_color"
        case merge = "merge_textures"
    }
    
    private var computePipelineStates: [TGComputePipelineType: MTLComputePipelineState] = [:]
    private let dispatchGourp = DispatchGroup()
    
    init() {
        // load pipeline states in parallel
        for type in TGComputePipelineType.allCases {
            dispatchGourp.enter()
            makeComputePipelineState(usingFunctionNamed: type.rawValue) { pipelineState in
                computePipelineStates[type] = pipelineState
                dispatchGourp.leave()
            }
        }
    }
    
    private func makeComputePipelineState(
        usingFunctionNamed functionName: String,
        completionHandler: (MTLComputePipelineState) -> Void
    ) {
        let library = TGDevice.defaultLibrary
        guard let function = library.makeFunction(name: functionName) else {
            fatalError("Function \(functionName) not found in library.")
        }
        do {
            let pipelineState = try TGDevice.device.makeComputePipelineState(
                function: function
            )
            completionHandler(pipelineState)
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
}
