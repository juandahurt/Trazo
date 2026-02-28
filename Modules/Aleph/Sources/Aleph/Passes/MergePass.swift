import MetalKit
import Tartarus

class MergePass: Pass {
    let dirtyArea: Rect
    let isDrawing: Bool
    
    init(dirtyArea: Rect, isDrawing: Bool) {
        self.dirtyArea = dirtyArea
        self.isDrawing = isDrawing
    }
    
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        commandBuffer.pushDebugGroup("Merge")
        let targetTiles = ctx.canvasGrid.tiles(intersecting: dirtyArea)
        guard !targetTiles.isEmpty else { return }
       
        let rect = Rect(
            x: 0,
            y: 0,
            width: Float(TileGrid.tileSize),
            height: Float(TileGrid.tileSize)
        )
        var projectionMatrix = Float4x4(
            ortho: rect,
            near: 0,
            far: 1
        )
        
        for canvasTile in targetTiles {
            guard let tileTexture = TextureManager.findTexture(id: canvasTile.textureId)
            else { return }
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].texture = tileTexture
            descriptor.colorAttachments[0].loadAction = .load
            descriptor.colorAttachments[0].storeAction = .store
            
            guard let encoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: descriptor
            ) else { return }
            
            encoder.setVertexBytes(
                &projectionMatrix,
                length: MemoryLayout<Float4x4>.stride,
                index: 2
            )
            
            // quad vertices
            let origin = Point(x: 0, y: 0)
            let tileSize = Float(TileGrid.tileSize)
            let vertices: [Float] = [
                origin.x,               origin.y,           // top-left
                origin.x + tileSize,    origin.y,           // top-right
                origin.x,               origin.y + tileSize,// bottom-left
                origin.x + tileSize,    origin.y + tileSize // bottom-right
            ]
            let (verticesBuffer, verticesOffset) = ctx.bufferAllocator.alloc(vertices)
            encoder.setVertexBuffer(verticesBuffer, offset: verticesOffset, index: 0)
            
            let textCoord: [Float] = [
                0, 0,
                1, 0,
                0, 1,
                1, 1
            ]
            let (textureBuffer, textureOffset) = ctx.bufferAllocator.alloc(textCoord)
            encoder.setVertexBuffer(textureBuffer, offset: textureOffset, index: 1)
            
            let indices: [UInt16] = [
                0, 1, 2,
                1, 2, 3
            ]
            let (indicesBuffer, indicesOffset) = ctx.bufferAllocator.alloc(indices)
            
            for (index, layer) in ctx.document.layers.enumerated() {
                guard let pipelineState = PipelinesManager.pipeline(for: .merge(.normal))
                else { return }
                
                encoder.setRenderPipelineState(pipelineState)
                
                let sourceTile: Tile
                
                if isDrawing && index == ctx.document.currentLayerIndex {
                    sourceTile = ctx.strokeGrid.tiles[canvasTile.row][canvasTile.col]
                } else {
                    sourceTile = layer.tileGrid.tiles[canvasTile.row][canvasTile.col]
                }
                
                guard let sourceTileTexture = TextureManager.findTexture(
                    id: sourceTile.textureId
                ) else { return }
                encoder.setFragmentTexture(sourceTileTexture, index: 0)
                encoder
                    .drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: indices.count,
                        indexType: .uint16,
                        indexBuffer: indicesBuffer,
                        indexBufferOffset: indicesOffset
                    )
                canvasTile.isDirty = false
            }
            encoder.endEncoding()
        }
        
        commandBuffer.popDebugGroup()
    }
}
