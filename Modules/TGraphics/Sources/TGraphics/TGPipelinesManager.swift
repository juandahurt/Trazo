import Metal
import Foundation

class TGPipelinesManager {
    enum TGComputePipelineType: String, CaseIterable {
        case fill = "fill_color"
        case merge = "merge_textures"
    }
    
    var computePipelineStates = Array<MTLComputePipelineState?>(
        repeating: nil,
        count: TGComputePipelineType.allCases.count
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
            }
        }
    }
}
