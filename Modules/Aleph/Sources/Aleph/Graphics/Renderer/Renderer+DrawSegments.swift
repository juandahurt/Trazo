import Metal
import Tartarus

// MARK: - Draw segments
extension Renderer {
    func draw(
        segments: [StrokeSegment],
        shapeTextureId: TextureID,
        grayscaleTexture: Texture,
        strokeTexture: Texture
    ) {
        for segment in segments {
            draw(
                segment: segment,
                shapeTextureID: shapeTextureId,
                on: grayscaleTexture
            )
        }
        guard let commandBuffer = GPU.commandQueue.makeCommandBuffer() else { return }
        colorize(
            texture: grayscaleTexture,
            withColor: .black,
            on: strokeTexture,
            using: commandBuffer
        )
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func draw(
        segment segment: StrokeSegment,
        shapeTextureID: TextureID,
        on texture: Texture
    ) {
        // add blendmode to the brush
        // use the blend mode of the current brush
        // to draw the points
        guard let commandBuffer = GPU.commandQueue.makeCommandBuffer() else { return }
        commandBuffer.pushDebugGroup("Draw grayscale points")
        defer { commandBuffer.popDebugGroup() }
        // TODO: improve this search
        for index in 0..<64 {
            let tile = texture.tiles[index]
            if tile.bounds.intersects(with: segment.bounds) {
                // add dirty tile
                ctx.addDirtyIndex(index)
                print("debug: \(index) encontrado")
                
                guard let texture = TextureManager.findTexture(id: tile.textureId) else {
                    return
                }
                drawGrayscalePoints(
                    segment.points,
                    tileIndex: index,
                    shapeTextureID: shapeTextureID,
                    on: texture,
                    using: commandBuffer
                )
            }
        }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

// MARK: - Draw points
extension Renderer {
    func drawGrayscalePoints(
        _ points: [DrawablePoint],
        withOpacity opacity: Float = 1,
        tileIndex: Int,
        shapeTextureID: TextureID,
        on texture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard
            let pipelineState = PipelinesManager.renderPipeline(
                for: .drawGrayscalePoints
            ),
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
}

// MARK: - Colorize
extension Renderer {
    func colorize(
        texture: Texture,
        withColor color: Color,
        on outputTexture: Texture,
        using commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.pushDebugGroup("Colorize Texture \(texture.name)")
        defer { commandBuffer.popDebugGroup() }
        print("coloreando", ctx.getDirtyIndices())
        for index in ctx.getDirtyIndices() {
            let inputTile = texture.tiles[index]
            let outputTile = outputTexture.tiles[index]
            guard
                let mtlInputTexture = TextureManager.findTexture(id: inputTile.textureId),
                let mtlOutputTexture = TextureManager.findTexture(
                    id: outputTile.textureId
                )
            else {
                return
            }
            colorize(
                texture: mtlInputTexture,
                withColor: color,
                on: mtlOutputTexture,
                using: commandBuffer
            )
        }
    }
    
    private func colorize(
        texture: MTLTexture,
        withColor color: Color,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        guard
            let pipelineState = PipelinesManager.computePipeline(for: .colorize)
        else { return }
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(pipelineState)
        encoder?.setTexture(texture, index: 0)
        encoder?.setTexture(outputTexture, index: 1)
        var color = color
        encoder?.setBytes(
            &color,
            length: MemoryLayout<Color>.stride,
            index: 0
        )
        var debugColor = Color(.init([0, 0, 0, 0]))
        encoder?.setBytes(
            &debugColor,
            length: MemoryLayout<Color>.stride,
            index: 1
        )
        let (threadgroupsPerGrid, threadsPerThreadgroup) = calculateThreads(in: texture)
        encoder?.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        encoder?.endEncoding()
    }
}
