import MetalKit
import Tartarus

typealias TextureID = UInt

final class TextureManager {
    nonisolated(unsafe)
    static private var textures: [TextureID: MTLTexture] = [:]
   
    nonisolated(unsafe)
    static private var tiledTextures: [TextureID: Texture] = [:]
    
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
    
    static func findTiledTexture(id: TextureID) -> Texture? {
        guard let tiledTexture = tiledTextures[id] else {
            print("tiled texture \(id) not found")
            return nil
        }
        return tiledTexture
    }
    
    static func makeTexture(ofSize size: Size, label: String? = nil) -> TextureID? {
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.width = Int(size.width)
        descriptor.height = Int(size.height)
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let texture = GPU.device.makeTexture(descriptor: descriptor) else {
            assert(false, "texture could not be created.")
        }
        texture.label = label
        return storeTexture(texture)
    }
    
    static func makeTiledTexture(
        named name: String,
        rows: Int,
        columns: Int,
        tileSize: Size,
        canvasSize: Size
    ) -> TextureID {
        var tiledTexture = Texture(name: name)
        for row in 0..<rows {
            for col in 0..<columns {
                var position = Point(
                    x: -canvasSize.width / 2 + Float(col) * tileSize.width,
                    y: canvasSize.height / 2 - Float(row) * tileSize.height
                )
                if let textureId = makeTexture(
                    ofSize: tileSize,
                    label: "\(name) (\(row),\(col))"
                ) {
                    tiledTexture.tiles.append(
                        .init(
                            bounds: .init(
                                x: position.x,
                                y: position.y,
                                width: tileSize.width,
                                height: tileSize.height
                            ),
                            textureId: textureId
                        )
                    )
                }
            }
        }
        return storeTiledTexture(tiledTexture)
    }
    
    private static func storeTexture(_ texture: MTLTexture) -> TextureID {
        print("storing texture", currId + 1)
        currId += 1
        textures[currId] = texture
        return currId
    }
    
    private static func storeTiledTexture(_ texture: Texture) -> TextureID {
        print("storing tiled texture", currId + 1)
        currId += 1
        tiledTextures[currId] = texture
        return currId
    }
}
