//
//  Renderer.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

import MetalKit

typealias Color = (r: Float, g: Float, b: Float, a: Float)

final class Renderer {
    private init() {}
   
    
    let threadGroupLength = 8 // TODO: move this to some global scope?
    static let instance = Renderer()
    
    func fillTexture(
        texture: DrawableTexture,
        with color: Color,
        using commandBuffer: MTLCommandBuffer
    ) {
        let colorBuffer: [Float] = [
            color.r,
            color.g,
            color.b,
            color.a
        ]
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(PipelinesStore.instance.fillColorPipeline)
        encoder?.setTexture(texture.actualTexture, index: 0)
        encoder?.setBytes(colorBuffer, length: MemoryLayout<Float>.stride * 4, index: 1)
        
        let threadsGroupSize = MTLSize(
            width: (texture.actualTexture.width) / threadGroupLength,
            height: texture.actualTexture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (texture.actualTexture.width) / threadsGroupSize.width,
            height: (texture.actualTexture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
    
    
    func substractTexture(
        texture: DrawableTexture,
        from destTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        ctm: CGAffineTransform = .identity
    ) {
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = destTexture
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].loadAction = .load
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(PipelinesStore.instance.removePointsPipeline)
        encoder?.setTexture(texture.actualTexture, index: 0)
        encoder?.setTexture(destTexture, index: 1)
        encoder?.setTexture(destTexture, index: 2)
            
        let threadsGroupSize = MTLSize(
            width: (texture.actualTexture.width) / threadGroupLength,
            height: texture.actualTexture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (texture.actualTexture.width) / threadsGroupSize.width,
            height: (texture.actualTexture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
       
        encoder?.endEncoding()
    }
    
    
    
    func drawTexture(
        texture: DrawableTexture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        backgroundColor: Color,
        ctm: CGAffineTransform = .identity
    ) {
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = .init(
            red: Double(backgroundColor.r),
            green: Double(backgroundColor.g),
            blue: Double(backgroundColor.b),
            alpha: Double(backgroundColor.a)
        )
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(PipelinesStore.instance.drawTexturePipeline)
        encoder?.setFragmentTexture(texture.actualTexture, index: 3)
        
        let width = Float(outputTexture.width)
        let height = Float(outputTexture.height)
        let vertices: [Float] = [
             -width / 2, -height / 2,
              width / 2, -height / 2,
              -width / 2, height / 2,
            width / 2, height / 2,
        ]
        
        let vertexBuffer = Metal.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Float>.stride * vertices.count
        )
        
        encoder?.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        
        
        encoder?.setVertexBytes(
            texture.buffers.textCoordinates,
            length: texture.buffers.textCoordSize,
            index: 1
        )
        
        // matrix transform
        var modelMatrix = ctm.toFloat4x4()
       
        let viewSize: Float = height
        let aspect = width / height
        let rect = CGRect(
            x: Double(-viewSize * aspect) * 0.5,
            y: Double(viewSize) * 0.5,
            width: Double(viewSize * aspect),
            height: Double(viewSize))
        var projection = float4x4(
            orthographic: rect,
            near: 0,
            far: 1
        )
        
        encoder?.setVertexBytes(
            &modelMatrix,
            length: MemoryLayout<float4x4>.stride,
            index: 2
        )
        encoder?.setVertexBytes(
            &projection,
            length: MemoryLayout<float4x4>.stride,
            index: 3
        )
        encoder?
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: texture.buffers.numIndices,
                indexType: .uint16,
                indexBuffer: texture.buffers.indexBuffer,
                indexBufferOffset: 0
            )
        encoder?.endEncoding()
    }
    
    // TODO: create model for grayscale positions
    func drawGrayPoints(
        positionsBuffer: MTLBuffer,
        numPoints: Int,
        on grayScaleTexture: MTLTexture,
        ctm: CGAffineTransform,
        using commandBuffer: MTLCommandBuffer
    ) {
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = grayScaleTexture
        passDescriptor.colorAttachments[0].loadAction = .load
        passDescriptor.colorAttachments[0].storeAction = .store
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(
            PipelinesStore.instance.drawGrayScalePointPipeline
        )
        encoder?.setVertexBuffer(positionsBuffer, offset: 0, index: 0)
        
        let width = Float(grayScaleTexture.width)
        let height = Float(grayScaleTexture.height)
        
        var modelMatrix = ctm.toFloat4x4()

        let viewSize: Float = height
        let aspect = width / height
        let rect = CGRect(
            x: Double(-viewSize * aspect) * 0.5,
            y: Double(viewSize) * 0.5,
            width: Double(viewSize * aspect),
            height: Double(viewSize))
        var projection = float4x4(
            orthographic: rect,
            near: 0,
            far: 1
        )
        
        encoder?.setVertexBytes(
            &modelMatrix,
            length: MemoryLayout<float4x4>.stride,
            index: 1
        )
        encoder?.setVertexBytes(
            &projection,
            length: MemoryLayout<float4x4>.stride,
            index: 2
        )
        
        
        encoder?.drawPrimitives(
            type: .point,
            vertexStart: 0,
            vertexCount: numPoints
        )
        encoder?.endEncoding()
    }
    
    func colorize(
        grayscaleTexture texture: MTLTexture,
        withColor color: Color,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
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
        encoder?.setComputePipelineState(PipelinesStore.instance.colorizePipeline)
        encoder?.setTexture(texture, index: 0)
        encoder?.setTexture(outputTexture, index: 1)
        var color = color
        encoder?.setBytes(
            &color,
            length: MemoryLayout<Color>.stride,
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
        to destinationTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        merge(
            sourceTexture,
            with: destinationTexture,
            on: destinationTexture,
            using: commandBuffer
        )
    }
    
    func merge(
        _ sourceTexture: MTLTexture,
        with secondTexture: MTLTexture,
        on destinationTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer
    ) {
        assert(sourceTexture.width == secondTexture.width)
        assert(sourceTexture.height == secondTexture.height)
        
        let threadsGroupSize = MTLSize(
            width: (destinationTexture.width) / threadGroupLength,
            height: destinationTexture.height / threadGroupLength,
            depth: 1
        )
        // TODO: check this little equation
        let threadsPerThreadGroup = MTLSize(
            width: (destinationTexture.width) / threadsGroupSize.width,
            height: (destinationTexture.height) / threadsGroupSize.height,
            depth: 1
        )
        
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(PipelinesStore.instance.mergePipeline)
        encoder?.setTexture(sourceTexture, index: 0)
        encoder?.setTexture(secondTexture, index: 1)
        encoder?.setTexture(destinationTexture, index: 2)
        encoder?
            .dispatchThreadgroups(
                threadsGroupSize,
                threadsPerThreadgroup: threadsPerThreadGroup
            )
        encoder?.endEncoding()
    }
}
