import Metal
import Tartarus

typealias TextureID = UInt

final class TextureManager {
    nonisolated(unsafe)
    static private var textures: [TextureID: MTLTexture] = [:]
    
    nonisolated(unsafe)
    static private var currId: TextureID = 0
    
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
        }
        texture.label = label
        return storeTexture(texture)
    }
    
    static func makeTiledTexture(
        named name: String,
        rows: Int,
        columns: Int,
        tileSize: Size
    ) -> TiledTexture {
        var tiledTexture = TiledTexture(name: name)
        for row in 0..<rows {
            for col in 0..<columns {
                let position = Point(x: 0, y: 0)
                if let textureId = makeTexture(
                    ofSize: tileSize,
                    label: "\(name) (\(row),\(col)"
                ) {
                    tiledTexture.tiles.append(
                        .init(
                            position: position,
                            textureId: textureId
                        )
                    )
                }
            }
        }
        return tiledTexture
    }
    
    private static func storeTexture(_ texture: MTLTexture) -> TextureID {
        textures[currId] = texture
        currId += 1
        return currId
    }
}
