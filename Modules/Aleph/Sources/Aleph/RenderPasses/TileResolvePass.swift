//import MetalKit
//
//class TileResolvePass: RenderPass {
//    let onlyDirtyTiles: Bool
//    
//    init(onlyDirtyTiles: Bool) {
//        self.onlyDirtyTiles = onlyDirtyTiles
//    }
//    
//    func encode(
//        context: FrameContext,
//        resources: RenderResources,
//        commandBuffer: any MTLCommandBuffer,
//        drawable: any CAMetalDrawable
//    ) {
//        commandBuffer.pushDebugGroup("Copy texture")
//        defer { commandBuffer.popDebugGroup() }
//        guard let destTexture = TextureManager.findTexture(id: resources.intermidiateTexture)
//        else { return }
//        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
//        let indices = onlyDirtyTiles ? context.dirtyTiles : Set(0..<(resources.rows * resources.cols))
//        for index in indices {
//            guard
//                let srcTiledTexture = TextureManager.findTiledTexture(id: resources.renderableTexture)
//            else { return }
//            let srcTile = srcTiledTexture.tiles[index]
//            guard let srcTexture = TextureManager.findTexture(id: srcTile.textureId)
//            else { return }
//            let row = index / resources.cols
//            blitEncoder?
//                .copy(
//                    from: srcTexture,
//                    sourceSlice: 0,
//                    sourceLevel: 0,
//                    sourceOrigin: .init(x: 0, y: 0, z: 0),
//                    sourceSize: .init(
//                        width: srcTexture.width,
//                        height: srcTexture.height,
//                        depth: 1
//                    ),
//                    to: destTexture,
//                    destinationSlice: 0,
//                    destinationLevel: 0,
//                    destinationOrigin: .init(
//                        x: Int(srcTile.bounds.x),
//                        y: Int(resources.canvasSize.height) - Int(
//                            Float(row) * srcTile.bounds.height
//                        ) - Int(resources.tileSize.height),
//                        z: 0
//                    )
//                )
//        }
//        blitEncoder?.endEncoding()
//    }
//}
