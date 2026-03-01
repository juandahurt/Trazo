import MetalKit
import Tartarus

class StrokePass: Pass {
    let segments: [StrokeSegment]

    init(segments: [StrokeSegment]) {
        self.segments = segments
    }

    func encode(
        commandBuffer: MTLCommandBuffer,
        drawable: CAMetalDrawable,
        ctx: Context
    ) {
        commandBuffer.pushDebugGroup("Stroke Pass")
        defer { commandBuffer.popDebugGroup() }

        guard let pipeline = PipelinesManager.pipeline(
            for: .stroke(ctx.brush.blendMode)
        ) else { return }

        guard let shapeTexture = TextureManager.findTexture(
            id: ctx.brush.shapeTextureID
        ) else { return }

        guard let granularityTexture = TextureManager.findTexture(
            id: ctx.brush.granularityTextureID
        ) else { return }
        
        let dirtyArea = segments.boundsUnion().clip(
            Rect(x: 0, y: 0,
                 width:  ctx.canvasSize.width,
                 height: ctx.canvasSize.height)
        )
        let affectedTiles = ctx.strokeGrid.tiles(intersecting: dirtyArea)
        guard !affectedTiles.isEmpty else { return }

        let points = segments.reduce([], { $0 + $1.points })
        guard !points.isEmpty else { return }

        let (pointsBuf, pointsOff) = ctx.bufferAllocator.alloc(points)

        let quadVertices: [Float] = [
            -0.5, -0.5,
            -0.5,  0.5,
             0.5, -0.5,
             0.5,  0.5
        ]
        let (quadBuf, quadOff) = ctx.bufferAllocator.alloc(quadVertices)

        let uvs: [Float] = [
            0, 0,
            1, 0,
            0, 1,
            1, 1
        ]
        let (uvBuf, uvOff) = ctx.bufferAllocator.alloc(uvs)

        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        let (iBuf, iOff) = ctx.bufferAllocator.alloc(indices)

        var opacity: Float = ctx.brush.opacity
        // TODO: use selected color
        var color = Color([0.19, 0.211, 0.219, 1])

        for tile in affectedTiles {
            guard let tileTexture = TextureManager.findTexture(id: tile.textureId)
            else { return }

            var tileProjection = makeTileProjection(tile: tile)

            let rpd = MTLRenderPassDescriptor()
            rpd.colorAttachments[0].texture     = tileTexture
            rpd.colorAttachments[0].loadAction  = .load
            rpd.colorAttachments[0].storeAction = .store

            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
            else { continue }

            encoder.setRenderPipelineState(pipeline)

            encoder.setVertexBuffer(quadBuf,   offset: quadOff,   index: 0)
            encoder.setVertexBuffer(uvBuf,     offset: uvOff,     index: 4)
            encoder.setVertexBuffer(pointsBuf, offset: pointsOff, index: 3)

            encoder.setVertexBytes(
                &tileProjection,
                length: MemoryLayout<Float4x4.Matrix>.stride,
                index: 1
            )
            encoder.setVertexBytes(&opacity, length: MemoryLayout<Float>.stride, index: 2)
            encoder.setVertexBytes(&color,   length: MemoryLayout<Color>.size,   index: 5)

            encoder.setFragmentTexture(shapeTexture,       index: 0)
            encoder.setFragmentTexture(granularityTexture, index: 1)

            encoder.drawIndexedPrimitives(
                type:              .triangle,
                indexCount:        indices.count,
                indexType:         .uint16,
                indexBuffer:       iBuf,
                indexBufferOffset: iOff,
                instanceCount:     points.count
            )

            encoder.endEncoding()
            tile.isDirty = true
        }
        commandBuffer.popDebugGroup()
    }

    private func makeTileProjection(tile: Tile) -> Float4x4 {
        let tileSize = Float(TileGrid.tileSize)
        let rect = Rect(
            x: tile.origin.x,
            y: tile.origin.y,
            width: tileSize,
            height: tileSize
        )
        return Float4x4(ortho: rect, near: 0, far: 1)
    }
}

extension Collection where Element == StrokeSegment {
    func boundsUnion() -> Rect {
        guard let first else { return .zero }
        
        let firstRect = first.bounds
        
        return reduce(firstRect, { $0.union($1.bounds) })
    }
}
