import Metal
import QuartzCore
import Tartarus

struct RendererContext {
    var dirtyIndices: Set<Int> = .init((0...63))
    var ctm: Transform = .identity
    var cpm: Transform = .identity
    var tileSize: Size = .zero
    var canvasSize: Size = .zero
    let clearColor = Color([0.93, 0.93, 0.93, 1])
}

// TODO: use a single buffer for drawing points
// TODO: maybe use a non-tiled texture for the renderable texture (?)
//       it seems that it always clears the view, so maybe using a texture
//       and copying only the affected tiles to the desired regions of the texture
//       will do the trick
class Renderer {
    var commandBuffer: MTLCommandBuffer?
    var ctx = RendererContext()
    
    var pointsBuffer: MTLBuffer?
   
    init() {
        commandBuffer = GPU.commandQueue.makeCommandBuffer()
        pointsBuffer = GPU.device.makeBuffer(
            length: MemoryLayout<DrawablePoint>.stride * 250,
            options: .storageModeShared
        )
    }
    
    func reset() {
        commandBuffer = GPU.commandQueue.makeCommandBuffer()
        ctx.dirtyIndices = []
    }
    
    func commit() {
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }
    
    func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    func draw(
        segment segment: StrokeSegment,
        shapeTextureID: TextureID,
        on texture: Texture
    ) {
        guard let commandBuffer else { return }
        // add blendmode to the brush
        // use the blend mode of the current brush
        // to draw the points
        commandBuffer.pushDebugGroup("draw grayscale points")
        defer { commandBuffer.popDebugGroup() }
        // TODO: improve this search
        for index in 0..<64 {
            let tile = texture.tiles[index]
            if tile.bounds.intersects(with: segment.bounds) {
                // add dirty tile
                ctx.dirtyIndices.insert(index)
                
                guard let texture = TextureManager.findTexture(id: tile.textureId) else {
                    return
                }
                drawGrayscalePoints(
                    segment.points,
                    tileIndex: index,
                    shapeTextureID: shapeTextureID,
                    on: texture
                )
            }
        }
    }
    
    func drawGrayscalePoints(
        _ points: [DrawablePoint],
        withOpacity opacity: Float = 1,
        tileIndex: Int,
        shapeTextureID: TextureID,
        on texture: MTLTexture
    ) {
        guard
            let pipelineState = PipelinesManager.renderPipeline(
                for: .drawGrayscalePoints
            ),
            let commandBuffer,
            let shapeTexture = TextureManager.findTexture(id: shapeTextureID)
        else {
            return
        }
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = .load
        passDescriptor.colorAttachments[0].storeAction = .store
        
        // update points buffer
        var data = pointsBuffer?.contents().bindMemory(
            to: [DrawablePoint].self,
            capacity: points.count
        )
        var points = points
        memcpy(
            pointsBuffer?.contents(),
            &points,
            MemoryLayout<DrawablePoint>.stride * points.count
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
        encoder?.setVertexBuffer(pointsBuffer, offset: 0, index: 0)
        
        var opacity = opacity
        // we need to transform the point coord from canvas coords
        // to the tiles coords
        let row = 8 - tileIndex / 8
        let col = tileIndex % 8
        var matrix = Transform.identity
        matrix = matrix
            .concatenating(.init(scaledByX: 1, y: -1))
            .concatenating(
                .init(
                    translateByX: ctx.canvasSize.width / Float(2),
                    y: ctx.canvasSize.height / Float(2)
                )
            )
            .concatenating(
                .init(
                    translateByX: -Float(col) * ctx.tileSize.width,
                    y: -Float(row) * ctx.tileSize.height
                )
            )
            .concatenating(
                .init(
                    translateByX: -ctx.tileSize.width / 2,
                    y: ctx.tileSize.height / 2
                )
            )
        var transform = matrix.concatenating(ctx.ctm.inverse)
        encoder?.setVertexBytes(
            &transform,
            length: MemoryLayout<Transform.Matrix>.stride,
            index: 1
        )
        let viewSize = Float(texture.height)
        let aspect = Float(texture.width) / Float(texture.height)
        let rect = Rect(
            x: -viewSize * aspect * 0.5,
            y: viewSize * 0.5,
            width: viewSize * aspect,
            height: viewSize
        )
        var pm = Transform(
            ortho: rect,
            near: 0,
            far: 1
        )
        encoder?.setVertexBytes(
            &pm,
            length: MemoryLayout<Transform.Matrix>.stride,
            index: 2
        )
        encoder?.setVertexBytes(
            &opacity,
            length: MemoryLayout<Float>.stride,
            index: 3
        )
        
        encoder?.setFragmentTexture(shapeTexture, index: 0)
        //        encoder?.setFragmentTexture(granularityTexture, index: 1)
        
        encoder?.drawPrimitives(
            type: .point,
            vertexStart: 0,
            vertexCount: points.count
        )
        encoder?.endEncoding()
    }
    
    func fillTexture(_ texture: Texture, color: Color, onlyDirtTiles: Bool = false) {
        commandBuffer?.pushDebugGroup("Fill \(texture.name)")
        let indices = onlyDirtTiles ? ctx.dirtyIndices : .init((0...63))
        for index in indices {
            let tile = texture.tiles[index]
            if let mtlTexture = TextureManager.findTexture(id: tile.textureId) {
                fillTexture(mtlTexture, color: color)
            }
        }
        commandBuffer?.popDebugGroup()
    }
    
    func drawTiledTexture(
        _ tiledTexture: Texture,
        on outputTexture: MTLTexture,
        using encoder: MTLRenderCommandEncoder
    ) {
        guard let pipelineState = PipelinesManager.renderPipeline(for: .drawTexture)
        else { return }
        encoder.setRenderPipelineState(pipelineState)
        for tile in tiledTexture.tiles {
            if let texture = TextureManager.findTexture(id: tile.textureId) {
                encoder.setFragmentTexture(texture, index: 3)
                
                let vertices: [Float] = [
                    tile.bounds.x, tile.bounds.y, // top left
                    tile.bounds.x + Float(texture.width), tile.bounds.y, // top right
                    tile.bounds.x, tile.bounds.y - Float(texture.height), // bottom left
                    tile.bounds.x + Float(texture.width), tile.bounds.y - Float(
                        texture.height
                    ), // bottom right
                ]
                
                // TODO: Remove buffer creation for vertex
                let vertexBuffer = GPU.device.makeBuffer(
                    bytes: vertices,
                    length: MemoryLayout<Float>.stride * vertices.count
                )
                
                encoder.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: 0
                )
                
                encoder.setVertexBuffer(
                    Buffer.quad.textureBuffer,
                    offset: 0,
                    index: 1
                )
                
                encoder.setVertexBytes(
                    &ctx.ctm,
                    length: MemoryLayout<Transform.Matrix>.stride,
                    index: 2
                )
                encoder.setVertexBytes(
                    &ctx.cpm,
                    length: MemoryLayout<Transform.Matrix>.stride,
                    index: 3
                )
                encoder
                    .drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: Buffer.quad.indexCount,
                        indexType: .uint16,
                        indexBuffer: Buffer.quad.indexBuffer,
                        indexBufferOffset: 0
                    )
            }
        }
        
        encoder.endEncoding()
    }
    
    func calculateThreads(in texture: MTLTexture) -> (
        groupsPerGrid: MTLSize,
        threadsPerGroup: MTLSize
    ) {
        let threadGroupLength = 8
        let threadsGroupsPerGrid = MTLSize(
            width: (texture.width + threadGroupLength - 1) / threadGroupLength,
            height: (texture.height + threadGroupLength - 1) / threadGroupLength,
            depth: 1
        )
        let threadsPerThreadGroup = MTLSize(
            width: threadGroupLength,
            height: threadGroupLength,
            depth: 1
        )
        return (threadsGroupsPerGrid, threadsPerThreadGroup)
    }
}
