import Metal
import QuartzCore
import Tartarus

class Renderer {
    private var commandBuffer: MTLCommandBuffer?
    
    func reset() {
        commandBuffer = GPU.commandQueue.makeCommandBuffer()
    }
    
    func commit() {
        commandBuffer?.commit()
    }
    
    func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    func fillTexture(_ texture: TiledTexture, color: Color) {
        for tile in texture.tiles {
            if let mtlTexture = TextureManager.findTexture(id: tile.textureId) {
                fillTexture(mtlTexture, color: color)
            }
        }
    }
    
    func drawTiledTexture(
            _ tiledTexture: TiledTexture,
            on outputTexture: MTLTexture,
            clearColor: Color,
            transform: Transform,
            projection: Transform
        ) {
            guard
                let commandBuffer,
                let pipelineState = PipelinesManager.renderPipeline(
                for: .drawTexture
            ) else {
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

                    var posRelativeToCenter = tile.position
//                    posRelativeToCenter.x -= Float(outputTexture.width) / 2
//                    posRelativeToCenter.y -= Float(outputTexture.height) / 2
//                    posRelativeToCenter.y *= -1
//                    posRelativeToCenter.y -= Float(texture.height)
                    
                    let vertices: [Float] = [
                        posRelativeToCenter.x, posRelativeToCenter.y, // top left
                        posRelativeToCenter.x + Float(texture.width), posRelativeToCenter.y, // top right
                        posRelativeToCenter.x, posRelativeToCenter.y + Float(texture.height), // bottom left
                        posRelativeToCenter.x + Float(texture.width), posRelativeToCenter.y + Float(texture.height), // bottom right
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
                    
                    var modelMatrix = transform
                    var projectionMatrix = projection
                    
                    encoder?.setVertexBytes(
                        &modelMatrix,
                        length: MemoryLayout<Transform.Matrix>.stride,
                        index: 2
                    )
                    encoder?.setVertexBytes(
                        &projectionMatrix,
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
