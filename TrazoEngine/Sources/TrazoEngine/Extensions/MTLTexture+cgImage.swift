//
//  MTLTexture+cgImage.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 14/04/25.
//

import CoreGraphics
import Metal

public extension Texture {
    func cgImage() -> CGImage {
        let width = metalTexture.width
        let height = metalTexture.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let byteCount = bytesPerRow * height
        
        var rawData = [UInt8](repeating: 0, count: byteCount)
       
        metalTexture.getBytes(
            &rawData,
            bytesPerRow: bytesPerRow,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo.byteOrderDefault.union(
            .init(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        )
        
        guard let provider = CGDataProvider(
            data: NSData(bytes: &rawData, length: byteCount)
        ) else {
            fatalError("")
        }
        
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
    }
}
