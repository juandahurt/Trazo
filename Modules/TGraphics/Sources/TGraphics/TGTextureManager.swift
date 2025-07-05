import MetalKit
import simd

final class TGTextureManager {
    private var textureMap: [Int: MTLTexture] = [:]
    private var currentId = -1
  
    init() {
        // TODO: load shape and granurality default textures in another place
        loadTexture(fromFile: "h-spray-m", withExtension: "png")
        loadTexture(fromFile: "noise", withExtension: "png")
    }
    
    func texture(byId id: Int) -> MTLTexture? {
        let texture = textureMap[id]
        if texture == nil {
            print("couldn't find texture", id)
        }
        return texture
    }
    
    func makeTexture(ofSize size: simd_long2, label: String? = nil) -> Int? {
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.width = size.x
        descriptor.height = size.y
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let texture = TGDevice.device.makeTexture(descriptor: descriptor)
        else { return nil}
        
        texture.label = label
        
        return storeTexture(texture)
    }
    
    func loadTexture(fromFile name: String, withExtension ext: String) -> Int? {
        let textureLoader = MTKTextureLoader(device: TGDevice.device)
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
    
    private func storeTexture(_ texture: MTLTexture) -> Int {
        textureMap[currentId + 1] = texture
        currentId += 1
        return currentId
    }
}
