//
//  TGTextureManager.swift
//  TGraphics
//
//  Created by Juan Hurtado on 30/05/25.
//

import Metal
import simd

public class TGTextureManager {
    private var textureMap: [Int: MTLTexture] = [:]
    private var currentId = -1
    
    func makeTexture(ofSize size: simd_long2, label: String? = nil) -> Int? {
        currentId += 1
        
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.width = size.x
        descriptor.height = size.y
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let texture = device.makeTexture(descriptor: descriptor)
        else {
            currentId -= 1
            return nil
        }
        
        texture.label = label
        textureMap[currentId] = texture
        
        return currentId
    }
}
