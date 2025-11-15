import Metal
import QuartzCore
import Tartarus

struct RendererContext {
    var ctm: Transform = .identity
    var cpm: Transform = .identity
}

class Renderer {
    private var commandBuffer: MTLCommandBuffer?
    var ctx = RendererContext()
    
    func reset() {
        commandBuffer = GPU.commandQueue.makeCommandBuffer()
    }
    
    func commit() {
        commandBuffer?.commit()
    }
    
    func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    func drawGrayscalePoints(
        _ points: [DrawablePoint],
        withOpacity opacity: Float = 1,
        on grayScaleTexture: Texture
    ) {
        guard
            let pipelineState = PipelinesManager.renderPipeline(
                for: .drawGrayscalePoints
            ),
            let commandBuffer
        else {
            return
        }
        // add blendmode to the brush
        // use the blend mode of the current brush
        // to draw the points
        commandBuffer.pushDebugGroup("draw grayscale points")
        defer { commandBuffer.popDebugGroup() }
        
        guard let texture = TextureManager.findTexture(
            id: grayScaleTexture.tiles.first!.textureId
        ) else { return }
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .dontCare
        
        let positionsBuffer = GPU.device.makeBuffer(
            bytes: points,
            length: MemoryLayout<DrawablePoint>.stride * points.count
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
        encoder?.setVertexBuffer(positionsBuffer, offset: 0, index: 0)
        
        var opacity = opacity
        
        encoder?.setVertexBytes(
            &ctx.ctm,
            length: MemoryLayout<Transform.Matrix>.stride,
            index: 1
        )
        encoder?.setVertexBytes(
            &ctx.cpm,
            length: MemoryLayout<Transform.Matrix>.stride,
            index: 2
        )
        encoder?.setVertexBytes(
            &opacity,
            length: MemoryLayout<Float>.stride,
            index: 3
        )
        
        //        encoder?.setFragmentTexture(shapeTexture, index: 0)
        //        encoder?.setFragmentTexture(granularityTexture, index: 1)
        
        encoder?.drawPrimitives(
            type: .point,
            vertexStart: 0,
            vertexCount: points.count
        )
        encoder?.endEncoding()
    }
    
    func fillTexture(_ texture: Texture, color: Color) {
        for tile in texture.tiles {
            if let mtlTexture = TextureManager.findTexture(id: tile.textureId) {
                fillTexture(mtlTexture, color: color)
            }
        }
    }
    
    func drawTiledTexture(
        _ tiledTexture: Texture,
        on outputTexture: MTLTexture,
        clearColor: Color
    ) {
        guard
            let commandBuffer,
            let pipelineState = PipelinesManager.renderPipeline(for: .drawTexture)
        else {
            return
        }
        
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = .init(
            red: Double(clearColor.r),
            green: Double(clearColor.g),
            blue: Double(clearColor.b),
            alpha: Double(clearColor.a)
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
        
        for tile in tiledTexture.tiles {
            if let texture = TextureManager.findTexture(id: tile.textureId) {
                encoder?.setFragmentTexture(texture, index: 3)
                
                let vertices: [Float] = [
                    tile.position.x, tile.position.y, // top left
                    tile.position.x + Float(texture.width), tile.position.y, // top right
                    tile.position.x, tile.position.y + Float(texture.height), // bottom left
                    tile.position.x + Float(texture.width), tile.position.y + Float(texture.height), // bottom right
                ]
                
                // TODO: Remove buffer creation for vertex
                let vertexBuffer = GPU.device.makeBuffer(
                    bytes: vertices,
                    length: MemoryLayout<Float>.stride * vertices.count
                )
                
                encoder?.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: 0
                )
                
                encoder?.setVertexBuffer(
                    Buffer.quad.textureBuffer,
                    offset: 0,
                    index: 1
                )
                
                encoder?.setVertexBytes(
                    &ctx.ctm,
                    length: MemoryLayout<Transform.Matrix>.stride,
                    index: 2
                )
                encoder?.setVertexBytes(
                    &ctx.cpm,
                    length: MemoryLayout<Transform.Matrix>.stride,
                    index: 3
                )
                encoder?
                    .drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: Buffer.quad.indexCount,
                        indexType: .uint16,
                        indexBuffer: Buffer.quad.indexBuffer,
                        indexBufferOffset: 0
                    )
            }
        }
        
        encoder?.endEncoding()
    }
    
    private func fillTexture(_ texture: MTLTexture, color: Color) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .fill),
            let commandBuffer
        else {
            return
        }
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(
            [color.r, color.g, color.b, color.a],
            length: MemoryLayout<Float>.stride * 4,
            index: 1
        )
        let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(in: texture)
        encoder?.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        encoder?.endEncoding()
    }
    
    private func calculateThreads(in texture: MTLTexture) -> (
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
