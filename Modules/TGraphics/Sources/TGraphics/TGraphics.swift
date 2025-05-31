import Metal
import simd

public struct TGraphics {
    let textureManager = TGTextureManager()
    let renderer: TGRenderer
    
    var commandBuffer: MTLCommandBuffer?
   
    public init() {
        let pipelineManager = TGPipelinesManager()
        renderer = TGRenderer(pipelineManager: pipelineManager)
    }
   
    public func load() {
        renderer.load()
    }
    
    public func makeTexture(ofSize size: simd_long2, label: String? = nil) -> Int? {
        textureManager.makeTexture(ofSize: size, label: label)
    }
    
    public func fillTexture(_ textureId: Int, with color: simd_float4) {
        guard
            let texture = textureManager.texture(byId: textureId),
            let commandBuffer
        else { return }
        renderer.fillTexture(texture: texture, with: color, using: commandBuffer)
    }
}
