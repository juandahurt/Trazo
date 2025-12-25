import Metal
import QuartzCore
import Tartarus

class RendererContext {
    private var dirtyIndices: Set<Int> = .init((0...63))
    var ctm: Transform = .identity
    var cpm: Transform = .identity
    var tileSize: Size = .zero
    var canvasSize: Size = .zero
    let clearColor = Color([0.93, 0.93, 0.93, 1])
    
    let lockQueue = DispatchQueue(label: "renderer.context")
   
    func addDirtyIndex(_ index: Int) {
        lockQueue.async { [weak self] in
            guard let self else { return }
            dirtyIndices.insert(index)
        }
    }
    
    func setDirtyIndices(_ value: Set<Int>) {
        lockQueue.async { [weak self] in
            guard let self else { return }
            dirtyIndices = value
        }
    }
    
    func getDirtyIndices() -> Set<Int> {
        lockQueue.sync {
            dirtyIndices
        }
    }
}

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
        ctx.setDirtyIndices([])
    }
    
    func commit() {
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }
    
    func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
   
    func copy(
        sourceTiledTexture: Texture,
        destTextureID: TextureID
    ) {
        guard
            let destTexture = TextureManager.findTexture(id: destTextureID),
            let commandBuffer = GPU.commandQueue.makeCommandBuffer()
        else { return }
        commandBuffer.pushDebugGroup("Copy texture \(sourceTiledTexture.name)")
        defer { commandBuffer.popDebugGroup() }
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        print("debug: copiando", ctx.getDirtyIndices())
        for dirtyIndex in ctx.getDirtyIndices() {
            let tile = sourceTiledTexture.tiles[dirtyIndex]
            guard let srcTexture = TextureManager.findTexture(id: tile.textureId)
            else { return }
            let row = 8 - dirtyIndex / 8
            blitEncoder?
                .copy(
                    from: srcTexture,
                    sourceSlice: 0,
                    sourceLevel: 0,
                    sourceOrigin: .init(x: 0, y: 0, z: 0),
                    sourceSize: .init(
                        width: srcTexture.width,
                        height: srcTexture.height,
                        depth: 1
                    ),
                    to: destTexture,
                    destinationSlice: 0,
                    destinationLevel: 0,
                    destinationOrigin: .init(
                        x: Int(ctx.canvasSize.width / 2 + tile.bounds.x),
                        y: Int(ctx.canvasSize.height - Float(row) * tile.bounds.height),
                        z: 0
                    )
                )
        }
        blitEncoder?.endEncoding()
        commandBuffer.commit()
    }
    
    func fillTexture(
        _ texture: Texture,
        color: Color,
        onlyDirtTiles: Bool = false,
        using commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.pushDebugGroup("Fill \(texture.name)")
        let indices = onlyDirtTiles ? ctx.getDirtyIndices() : .init((0...63))
        for index in indices {
            let tile = texture.tiles[index]
            if let mtlTexture = TextureManager.findTexture(id: tile.textureId) {
//                fillTexture(mtlTexture, color: color, using: commandBuffer)
            }
        }
        commandBuffer.popDebugGroup()
    }
    
    func drawTexture(
        _ textureID: TextureID,
        on outputTexture: MTLTexture,
        using encoder: MTLRenderCommandEncoder
    ) {
        guard let pipelineState = PipelinesManager.renderPipeline(for: .drawTexture)
        else { return }
        encoder.setRenderPipelineState(pipelineState)
        if let texture = TextureManager.findTexture(id: textureID) {
            encoder.setFragmentTexture(texture, index: 3)
            
            let vertices: [Float] = [
                Float(-texture.width / 2), Float(-texture.height / 2),// top left
                Float(texture.width / 2), Float(-texture.height / 2), // top right
                Float(-texture.width / 2), Float(texture.height / 2), // bottom left
                Float(texture.width / 2), Float(texture.height / 2) // bottom right
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
