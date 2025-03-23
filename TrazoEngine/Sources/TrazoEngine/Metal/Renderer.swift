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
}
