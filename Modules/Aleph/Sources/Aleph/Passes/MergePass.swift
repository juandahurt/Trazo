import MetalKit
import Tartarus

class MergePass: Pass {
    let dirtyArea: Rect
    
    let sourceGrids: [TileGrid]
    let destinationGrid: TileGrid
    let blitDestination: TextureID?
    let mustClearBackground: Bool
    
    init(
        dirtyArea: Rect,
        sourceGrids: [TileGrid],
        destinationGrid: TileGrid,
        blitDestination: TextureID?,
        mustClearBackground: Bool = false
    ) {
        self.dirtyArea = dirtyArea
        self.sourceGrids = sourceGrids
        self.destinationGrid = destinationGrid
        self.blitDestination = blitDestination
        self.mustClearBackground = mustClearBackground
    }
    
    func encode(
        commandBuffer: any MTLCommandBuffer,
        drawable: any CAMetalDrawable,
        ctx: Context
    ) {
        commandBuffer.pushDebugGroup("Merge to \(destinationGrid.name)")
        let targetTiles = destinationGrid.tiles(intersecting: dirtyArea)
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
            descriptor.colorAttachments[0].clearColor = Color.clear.mtlClearColor
            descriptor.colorAttachments[0].loadAction = mustClearBackground ? .clear : .load
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
            
            for sourceGrid in sourceGrids {
                guard let pipelineState = PipelinesManager.pipeline(for: .merge(.normal))
                else { return }
                
                encoder.setRenderPipelineState(pipelineState)
                
                let sourceTile = sourceGrid.tiles[canvasTile.row][canvasTile.col]
                
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
        
        guard let blitDestination else { return }
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
        guard let compositeTexture = TextureManager.findTexture(
            id: blitDestination
        ) else {
            commandBuffer.popDebugGroup()
            return
        }
        for tile in targetTiles {
            guard let tileTexture = TextureManager.findTexture(id: tile.textureId)
            else { return }
            
            let tileSize = TileGrid.tileSize
            let destX = Int(tile.origin.x)
            let destY = Int(tile.origin.y)
            let copyWidth = min(tileSize, compositeTexture.width - destX)
            let copyHeight = min(tileSize, compositeTexture.height - destY)
            
            blitEncoder.copy(
                 from: tileTexture,
                 sourceSlice: 0,
                 sourceLevel: 0,
                 sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                 sourceSize: MTLSize(
                    width: copyWidth,
                    height: copyHeight,
                    depth: 1
                 ),
                 to: compositeTexture,
                 destinationSlice: 0,
                 destinationLevel: 0,
                 destinationOrigin: MTLOrigin(
                    x: destX,
                    y: destY,
                    z: 0
                 )
             )
        }
        blitEncoder.endEncoding()
        
        commandBuffer.popDebugGroup()
    }
}
