import MetalKit
import Tartarus

public typealias TextureID = UInt

final class TextureManager {
    nonisolated(unsafe)
    static private var textures: [TextureID: MTLTexture] = [:]
    
    nonisolated(unsafe)
    static private var currId: TextureID = 0
   
    static func loadTexture(fromFile name: String, withExtension ext: String) -> TextureID? {
        let textureLoader = MTKTextureLoader(device: GPU.device)
        guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
            print("couldn't find a file named \(name).\(ext)")
            return nil
        }
        if let texture = try? textureLoader.newTexture(
            URL: url,
            options: [.textureUsage: MTLTextureUsage.shaderRead.rawValue]
        ) {
            return storeTexture(texture)
        } else {
            print("couldn't load texture \(name).\(ext)")
            return nil
        }
    }
    
    static func findTexture(id: TextureID) -> MTLTexture? {
        guard let texture = textures[id] else {
            print("texture \(id) not found") // TODO: use a logger
            return nil
        }
        return texture
    }
    
    static func makeTexture(ofSize size: Size, label: String? = nil) -> TextureID? {
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.width = Int(size.width)
        descriptor.height = Int(size.height)
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let texture = GPU.device.makeTexture(descriptor: descriptor) else {
            assert(false, "texture could not be created.")
            return nil
        }
        texture.label = label
        return storeTexture(texture)
    }
    
    private static func storeTexture(_ texture: MTLTexture) -> TextureID {
        currId += 1
        textures[currId] = texture
        return currId
    }
}
