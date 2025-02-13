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
    
    func drawTexture(
        texture: DrawableTexture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        backgroundColor: Color? = nil,
        ctm: CGAffineTransform = .identity
    ) {
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .load
        
        if let backgroundColor {
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor
                .colorAttachments[0].clearColor = .init(
                    red: Double(backgroundColor.r),
                    green: Double(backgroundColor.g),
                    blue: Double(backgroundColor.b),
                    alpha: Double(backgroundColor.a)
                )
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.setRenderPipelineState(PipelinesStore.instance.drawTexturePipeline)
        encoder?.setFragmentTexture(texture.actualTexture, index: 3)
        encoder?.setVertexBuffer(
            texture.buffers.vertexBuffer,
            offset: 0,
            index: 0
        )
        encoder?.setVertexBytes(
            texture.buffers.textCoordinates,
            length: texture.buffers.textCoordSize,
            index: 1
        )
        
        // matrix transform
        var matrix = float3x3([
            [Float(ctm.a), Float(ctm.b), 0],
            [Float(ctm.c), Float(ctm.d), 0],
            [Float(ctm.tx), Float(ctm.ty), 1]
        ])
        
        encoder?.setVertexBytes(
            &matrix,
            length: MemoryLayout<float3x3>.stride,
            index: 2
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
        assert(sourceTexture.width == destinationTexture.width)
        assert(sourceTexture.height == destinationTexture.height)
        
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
        encoder?.setTexture(destinationTexture, index: 1)
        encoder?.setTexture(destinationTexture, index: 2)
        encoder?
            .dispatchThreadgroups(
                threadsGroupSize,
                threadsPerThreadgroup: threadsPerThreadGroup
            )
        encoder?.endEncoding()
    }
}
