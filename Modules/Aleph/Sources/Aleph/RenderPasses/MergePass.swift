import MetalKit

class MergePass: RenderPass {
    //    let layersTexturesIds: [TextureID]
    //    let onlyDirtyIndices: Bool
    //    let isDrawing: Bool
    //    let currentLayerIndex: Int
    //
    //    init(
    //        layersTexturesIds: [TextureID],
    //        onlyDirtyIndices: Bool,
    //        isDrawing: Bool,
    //        currentLayerIndex: Int
    //    ) {
    //        self.layersTexturesIds = layersTexturesIds
    //        self.onlyDirtyIndices = onlyDirtyIndices
    //        self.isDrawing = isDrawing
    //        self.currentLayerIndex = currentLayerIndex
    //    }
    
    func encode(
        context: SceneContext,
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable
    ) {
        for index in stride(
            from: context.layersContext.layers.count - 1,
            to: -1,
            by: -1
        ) {
            let layerTextureId = context.layersContext.layers[index].texture
            guard
                let layerTexture = TextureManager.findTexture(id: layerTextureId),
                //                let strokeTexture = TextureManager.findTiledTexture(
                //                    id: resources.strokeTexture
                    //                ),
                    let outputTexture = TextureManager.findTexture(
                        id: context.renderContext.renderableTexture
                    )
            else {
                return
            }
            merge(
                outputTexture,
                with: layerTexture,
                on: outputTexture,
                using: commandBuffer,
                renderContext: context.renderContext
            )
        }
    }
    
    func merge(
        _ sourceTexture: MTLTexture,
        with secondTexture: MTLTexture,
        on destinationTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        renderContext: RenderContext
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .merge)
        else {
            return
        }
        let numTiles = 8
        let dirtyTiles = [Int](repeatElement(0, count: numTiles)).map { _ in
            Int.random(in: 0...120)
        }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(sourceTexture, index: 0)
        encoder?.setTexture(secondTexture, index: 1)
        encoder?.setTexture(destinationTexture, index: 2)
        
//        for dirtyTile in dirtyTiles {
//            let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(
//                in: renderContext.tileSize
//            )
//            encoder?.dispatchThreadgroups(
//                threadgroupsPerGrid,
//                threadsPerThreadgroup: threadsPerThreadgroup
//            )
//        }
//        
//        encoder?.endEncoding()
        
        let tiles: [TileRect] = [
            .init(
                origin: .init(
                    x: .random(in: 0...UInt32(renderContext.canvasSize.width)),
                    y: .random(in: 0...UInt32(renderContext.canvasSize.height))
                ),
                size: .init(x: 64, y: 64)
            ),
        ]
        let tileBuffer = GPU.device.makeBuffer(
            bytes: tiles,
            length: MemoryLayout<TileRect>.stride * tiles.count,
            options: []
        )!

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
    }
}

fileprivate struct TileRect {
    var origin: SIMD2<UInt32>
    var size: SIMD2<UInt32>
}
