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
            //            if index == currentLayerIndex && isDrawing {
            //                merge(
            //                    strokeTexture,
            //                    with: layerTexture,
            //                    on: outputTexture,
            //                    using: commandBuffer,
            //                    context: context,
            //                    resources: resources
            //                )
            //            } else {
            //                merge(
            //                    outputTexture,
            //                    with: layerTexture,
            //                    on: outputTexture,
            //                    using: commandBuffer,
            //                    context: context,
            //                    resources: resources
            //                )
            //            }
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
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(sourceTexture, index: 0)
        encoder?.setTexture(secondTexture, index: 1)
        encoder?.setTexture(destinationTexture, index: 2)
        let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(
            in: sourceTexture
        )
        encoder?.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        //        }
        encoder?.endEncoding()
        commandBuffer.popDebugGroup()
    }
}
