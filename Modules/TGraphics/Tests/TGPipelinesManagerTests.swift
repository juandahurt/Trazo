import Foundation
@testable import TGraphics
import Testing

@Suite("PipelineManager tests")
struct TGPipelinesManagerTests {
    @Test("Load pipelines")
    func loadPipelines() {
        let manager = TGPipelinesManager()
        let start = Date()
        manager.load()
        let end = Date()
        let duration = end.timeIntervalSince(start)
        #expect(duration < 1)
        
        let loadedComputePipelinesCount = manager.computePipelineStates.count
        let computePipelineStatesCount = TGPipelinesManager.TGComputePipelineType.allCases.count
        
        #expect(loadedComputePipelinesCount == computePipelineStatesCount)
        
        for pipelineState in manager.computePipelineStates {
            #expect(pipelineState != nil)
        }
    }
}
