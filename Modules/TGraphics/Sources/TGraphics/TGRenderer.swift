import Metal
import simd

class TGRenderer {
    let threadGroupLength = 8
    let pipelineManager: TGPipelinesManager
    
    init(pipelineManager: TGPipelinesManager) {
        self.pipelineManager = pipelineManager
    }
    
    func load() {
        pipelineManager.load()
    }
   
    public func copy(
        texture: MTLTexture,
        on destinationTexture: MTLTexture,
        at destOrigin: simd_long2,
        commandBuffer: MTLCommandBuffer
    ) {
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        blitEncoder?
            .copy(
                from: texture,
                sourceSlice: 0,
                sourceLevel: 0,
                sourceOrigin: .init(x: 0, y: 0, z: 0),
                sourceSize: .init(
                    width: texture.width,
                    height: texture.height,
                    depth: 1
                ),
                to: destinationTexture,
                destinationSlice: 0,
                destinationLevel: 0,
                destinationOrigin: .init(
                    x: destOrigin.x,
                    y: destOrigin.y,
                    z: 0
                )
            )
        blitEncoder?.endEncoding()
    }
    
    public func copy(
        texture: MTLTexture,
        on destinationTexture: MTLTexture,
        commandBuffer: MTLCommandBuffer
    ) {
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        blitEncoder?.copy(from: texture, to: destinationTexture)
        blitEncoder?.endEncoding()
    }
    
    public func substract(
        textureA: MTLTexture,
        textureB: MTLTexture,
        on outputTexture: MTLTexture,
        commandBuffer: MTLCommandBuffer
    ) {
        guard let pipelineState = pipelineManager.computePipeline(ofType: .substract) else {
            return
        }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(textureA, index: 0)
        encoder?.setTexture(textureB, index: 1)
        encoder?.setTexture(outputTexture, index: 2)
        let threadsGroupSize = MTLSize(
            width: (textureA.width) / threadGroupLength,
            height: textureA.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (textureA.width) / threadsGroupSize.width,
            height: (textureA.height) / threadsGroupSize.height,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
    
    func fillTexture(
        texture: MTLTexture,
        with color: simd_float4,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard let pipelineState = pipelineManager.computePipeline(ofType: .fill) else {
            return
        }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(
            [color.x, color.y, color.z, color.w],
            length: MemoryLayout<Float>.stride * 4,
            index: 1
        )
        let threadsGroupsPerGrid = MTLSize(
            width: (texture.width + threadGroupLength - 1) / threadGroupLength,
            height: (texture.height + threadGroupLength - 1) / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: threadGroupLength,
            height: threadGroupLength,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
  
    func colorize(
        grayscaleTexture: TGTiledTexture,
        withColor color: simd_float4,
        on outputTexture: TGTiledTexture,
        dirtyTiles: Set<Int>,
        textureManager: TGTextureManager,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard
            let pipelineState = pipelineManager.computePipeline(ofType: .colorize)
        else { return }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        
        var color = color
        encoder?.setBytes(
            &color,
            length: MemoryLayout<simd_float4>.stride,
            index: 0
        )
        
        for tileIndex in dirtyTiles {
            
            if
                let tileTexture = textureManager.texture(
                    byId: grayscaleTexture.tiles[tileIndex].textureId
                ),
                let outputTileTexture = textureManager.texture(
                    byId: outputTexture.tiles[tileIndex].textureId
                )
            {
                encoder?.setTexture(tileTexture, index: 0)
                encoder?.setTexture(outputTileTexture, index: 1)
                
                let threadsGroupsPerGrid = MTLSize(
                    width: (tileTexture.width + threadGroupLength - 1) / threadGroupLength,
                    height: (tileTexture.height + threadGroupLength - 1) / threadGroupLength,
                    depth: 1
                )
                // TODO: check this little equation
                let threadsPerThreadGroup = MTLSize(
                    width: threadGroupLength,
                    height: threadGroupLength,
                    depth: 1
                )
                
                encoder?.dispatchThreadgroups(
                    threadsGroupsPerGrid,
                    threadsPerThreadgroup: threadsPerThreadGroup
                )
            }
        }
        encoder?.endEncoding()
    }
    
    func colorize(
        grayscaleTexture texture: MTLTexture,
        withColor color: simd_float4,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard
            let pipelineState = pipelineManager.computePipeline(ofType: .colorize)
        else { return }
        let threadsGroupSize = MTLSize(
            width: (texture.width) / threadGroupLength,
            height: texture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (texture.width) / threadsGroupSize.width,
            height: (texture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(texture, index: 0)
        encoder?.setTexture(outputTexture, index: 1)
        var color = color
        encoder?.setBytes(
            &color,
            length: MemoryLayout<simd_float4>.stride,
            index: 0
        )
        encoder?
            .dispatchThreadgroups(
                threadsGroupSize,
                threadsPerThreadgroup: threadsPerThreadGroup
            )
        encoder?.endEncoding()
    }
    
    func merge(
        _ sourceTexture: MTLTexture,
        with secondTexture: MTLTexture,
        on destinationTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        assert(sourceTexture.width == secondTexture.width)
        assert(sourceTexture.height == secondTexture.height)
        
        guard let pipelineState = pipelineManager.computePipeline(ofType: .merge) else {
            return
        }
        
        let threadsGroupsPerGrid = MTLSize(
            width: (sourceTexture.width + threadGroupLength - 1) / threadGroupLength,
            height: (sourceTexture.height + threadGroupLength - 1) / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: threadGroupLength,
            height: threadGroupLength,
            depth: 1
        )
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(sourceTexture, index: 0)
        encoder?.setTexture(secondTexture, index: 1)
        encoder?.setTexture(destinationTexture, index: 2)
        encoder?.dispatchThreadgroups(
            threadsGroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
    
    func drawGrayscalePoints(
        positionsBuffer: MTLBuffer,
        numPoints: Int,
        withOpacity opacity: Float,
        on grayScaleTexture: MTLTexture,
        shapeTexture: MTLTexture,
        granularityTexture: MTLTexture,
        transform: simd_float4x4,
        projection: simd_float4x4,
        using commandBuffer: MTLCommandBuffer,
        clearingBackground: Bool
    ) {
        guard
            let pipelineState = pipelineManager.renderPipeline(ofType: .drawGrayScalePoints)
        else {
            return
        }
        
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = grayScaleTexture
        passDescriptor.colorAttachments[0].loadAction = .load
        passDescriptor.colorAttachments[0].storeAction = .store
        
        if clearingBackground {
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].clearColor = .init(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0
            )
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
        encoder?.setVertexBuffer(positionsBuffer, offset: 0, index: 0)
        
        var modelMatrix = transform
        var projectionMatrix = projection
        var opacity = opacity
        
        encoder?.setVertexBytes(
            &modelMatrix,
            length: MemoryLayout<simd_float4x4>.stride,
            index: 1
        )
        encoder?.setVertexBytes(
            &projectionMatrix,
            length: MemoryLayout<simd_float4x4>.stride,
            index: 2
        )
        encoder?.setVertexBytes(
            &opacity,
            length: MemoryLayout<Float>.stride,
            index: 3
        )
       
        encoder?.setFragmentTexture(shapeTexture, index: 0)
        encoder?.setFragmentTexture(granularityTexture, index: 1)
        
        encoder?.drawPrimitives(
            type: .point,
            vertexStart: 0,
            vertexCount: numPoints
        )
        encoder?.endEncoding()
    }
    
    func drawTiledTexture(
        _ tiledTexture: TGTiledTexture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        textureManager: TGTextureManager,
        clearColor: simd_float4,
        transform: simd_float4x4,
        projection: simd_float4x4
    ) {
        guard let pipelineState = pipelineManager.renderPipeline(
            ofType: .drawTexture
        ) else {
            return
        }
        
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = .init(
            red: Double(clearColor.x),
            green: Double(clearColor.y),
            blue: Double(clearColor.z),
            alpha: Double(clearColor.w)
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
    
        for tile in tiledTexture.tiles {
            if let texture = textureManager.texture(byId: tile.textureId) {
                encoder?.setFragmentTexture(texture, index: 3)

                var posRelativeToCenter = tile.position
                posRelativeToCenter.x -= Float(outputTexture.width) / 2
                posRelativeToCenter.y -= Float(outputTexture.height) / 2
                posRelativeToCenter.y *= -1
                posRelativeToCenter.y -= Float(texture.height)
                
                let vertices: [Float] = [
                    posRelativeToCenter.x, posRelativeToCenter.y, // top left
                    posRelativeToCenter.x + Float(texture.width), posRelativeToCenter.y, // top right
                    posRelativeToCenter.x, posRelativeToCenter.y + Float(texture.height), // bottom left
                    posRelativeToCenter.x + Float(texture.width), posRelativeToCenter.y + Float(texture.height), // bottom right
                ]
                
                let vertexBuffer = TGDevice.device.makeBuffer(
                    bytes: vertices,
                    length: MemoryLayout<Float>.stride * vertices.count
                )
                
                encoder?.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: 0
                )
                
                encoder?.setVertexBuffer(
                    QuadBuffers.textureBuffer,
                    offset: 0,
                    index: 1
                )
                
                var modelMatrix = transform
                var projectionMatrix = projection
                
                encoder?.setVertexBytes(
                    &modelMatrix,
                    length: MemoryLayout<simd_float4x4>.stride,
                    index: 2
                )
                encoder?.setVertexBytes(
                    &projectionMatrix,
                    length: MemoryLayout<simd_float4x4>.stride,
                    index: 3
                )
                encoder?
                    .drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: QuadBuffers.indexCount,
                        indexType: .uint16,
                        indexBuffer: QuadBuffers.indexBuffer,
                        indexBufferOffset: 0
                    )
            }
        }
        
        encoder?.endEncoding()
    }
    
    func drawTexture(
        _ texture: MTLTexture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        clearColor: simd_float4,
        transform: simd_float4x4,
        projection: simd_float4x4
    ) {
        guard let pipelineState = pipelineManager.renderPipeline(
            ofType: .drawTexture
        ) else {
            return
        }
        
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = .init(
            red: Double(clearColor.x),
            green: Double(clearColor.y),
            blue: Double(clearColor.z),
            alpha: Double(clearColor.w)
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
        encoder?.setFragmentTexture(texture, index: 3)
        
        let textureWidth = Float(outputTexture.width)
        let textureHeight = Float(outputTexture.height)
        let vertices: [Float] = [
            -textureWidth / 2, -textureHeight / 2,
             textureWidth / 2, -textureHeight / 2,
             -textureWidth / 2, textureHeight / 2,
             textureWidth / 2, textureHeight / 2,
        ]
        
        let vertexBuffer = TGDevice.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Float>.stride * vertices.count
        )
        
        encoder?.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        
        encoder?.setVertexBuffer(
            QuadBuffers.textureBuffer,
            offset: 0,
            index: 1
        )
        
        var modelMatrix = transform
        var projectionMatrix = projection
        
        encoder?.setVertexBytes(
            &modelMatrix,
            length: MemoryLayout<simd_float4x4>.stride,
            index: 2
        )
        encoder?.setVertexBytes(
            &projectionMatrix,
            length: MemoryLayout<simd_float4x4>.stride,
            index: 3
        )
        encoder?
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: QuadBuffers.indexCount,
                indexType: .uint16,
                indexBuffer: QuadBuffers.indexBuffer,
                indexBufferOffset: 0
            )
        encoder?.endEncoding()
    }
}
