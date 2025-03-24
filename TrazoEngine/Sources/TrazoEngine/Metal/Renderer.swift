//
//  Renderer.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

import Metal
import TrazoCore



@MainActor
final class Renderer {
    private init() {}
    
    static let threadGroupLength = 8 // TODO: move this to some global scope?
    
    static func fillTexture(
        texture: MTLTexture,
        with color: Vector4,
        using commandBuffer: MTLCommandBuffer
    ) {
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder?.setComputePipelineState(PipelinesStore.instance.fillColorPipeline)
        encoder?.setTexture(texture, index: 0)
        encoder?.setBytes(
            [color.x, color.y, color.z, color.w],
            length: MemoryLayout<Float>.stride * 4,
            index: 1
        )
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
        
        encoder?.dispatchThreadgroups(
            threadsGroupSize,
            threadsPerThreadgroup: threadsPerThreadGroup
        )
        encoder?.endEncoding()
    }
    
    static func merge(
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
    
    static func drawTexture(
        _ texture: MTLTexture,
        on outputTexture: MTLTexture,
        using commandBuffer: MTLCommandBuffer,
        clearColor: Vector4,
        transform: Mat4x4
    ) {
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
        encoder?.setRenderPipelineState(PipelinesStore.instance.drawTexturePipeline)
        encoder?.setFragmentTexture(texture, index: 3)
        
        let textureWidth = Float(outputTexture.width)
        let textureHeight = Float(outputTexture.height)
        let vertices: [Float] = [
            -textureWidth / 2, -textureHeight / 2,
             textureWidth / 2, -textureHeight / 2,
             -textureWidth / 2, textureHeight / 2,
             textureWidth / 2, textureHeight / 2,
        ]
        
        let vertexBuffer = GPU.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Float>.stride * vertices.count
        )
        
        encoder?.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        
        
//        encoder?.setVertexBytes(
//            texture.buffers.textCoordinates,
//            length: texture.buffers.textCoordSize,
//            index: 1
//        )
        encoder?.setVertexBuffer(
            QuadBuffers.textureBuffer,
            offset: 0,
            index: 1
        )
        
        // matrix transform
        let width = Float(outputTexture.width)
        let height = Float(outputTexture.height)

        var modelMatrix = transform
        let viewSize: Float = height
        let aspect = width / height
        let rect = CGRect(
            x: Double(-viewSize * aspect) * 0.5,
            y: Double(viewSize) * 0.5,
            width: Double(viewSize * aspect),
            height: Double(viewSize))
        var projection = Mat4x4(
            orthographic: rect,
            near: 0,
            far: 1
        )
        
        encoder?.setVertexBytes(
            &modelMatrix,
            length: MemoryLayout<Mat4x4>.stride,
            index: 2
        )
        encoder?.setVertexBytes(
            &projection,
            length: MemoryLayout<Mat4x4>.stride,
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
