import MetalKit

class FillPass: RenderPass {
    let color: Color
    let textureId: TextureID
    
    init(color: Color, textureId: TextureID) {
        self.color = color
        self.textureId = textureId
    }
    
    func encode(
        context: SceneContext,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .fill),
            !context.dirtyContext.dirtyIndices.isEmpty
        else {
            return
        }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        guard let texture = TextureManager.findTexture(id: textureId) else { return }
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(
            [color.r, color.g, color.b, color.a],
            length: MemoryLayout<Float>.stride * 4,
            index: 1
        )
        
        let tiles: [TileRect] = context.dirtyContext.dirtyIndices.map {
            let row = $0 / context.renderContext.cols
            let col = $0 % context.renderContext.cols
            let minX: UInt32 = UInt32(Float(col) * context.renderContext.tileSize.width)
            let minY: UInt32 = UInt32(Float(row) * context.renderContext.tileSize.height)
            return .init(
                origin: [minX, minY],
                size: [
                    UInt32(context.renderContext.tileSize.width),
                    UInt32(context.renderContext.tileSize.height)
                ]
            )
        }
        let tileBuffer = GPU.device.makeBuffer(
            bytes: tiles,
            length: MemoryLayout<TileRect>.stride * tiles.count,
            options: []
        )

        encoder?.setBuffer(tileBuffer, offset: 0, index: 0)
        let tgPerTile = 4
        let threadsPerTG = 16
        let threadgroups = MTLSize(
            width: tiles.count * tgPerTile,
            height: tgPerTile,
            depth: 1
        )

        let threadsPerThreadgroup = MTLSize(
            width: threadsPerTG,
            height: threadsPerTG,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadgroups,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        encoder?.endEncoding()
        return
        
    }
}

fileprivate struct TileRect {
    var origin: SIMD2<UInt32>
    var size: SIMD2<UInt32>
}
