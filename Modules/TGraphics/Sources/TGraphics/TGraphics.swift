import MetalKit
import simd

public class TGraphics {
    let textureManager = TGTextureManager()
    let renderer: TGRenderer
    
    var commandBuffer: MTLCommandBuffer?
   
    public init() {
        let pipelineManager = TGPipelinesManager()
        renderer = TGRenderer(pipelineManager: pipelineManager)
    }
   
    public func load() {
        renderer.load()
        reset()
    }
    
    public func makeTiledTexture(
        named name: String,
        rows: Int,
        cols: Int,
        tileWidth: Int,
        tileHeight: Int
    ) -> TGTiledTexture {
        var texture = TGTiledTexture(name: name)
        for row in 0..<rows {
            for col in 0..<cols {
                let tilePosX = Float(col) * Float(tileWidth)
                let tilePosY = Float(row) * Float(tileHeight)
                
                if let textureId = makeTexture(
                    ofWidth: tileWidth,
                    height: tileHeight,
                    label: "\(texture.name) (\(row),\(col))"
                ) {
                    let tile = TGTile(position: .init(x: tilePosX, y: tilePosY), textureId: textureId)
                    texture.tiles.append(tile)
                }
            }
        }
        return texture
    }
    
    public func makeTexture(ofWidth width: Int, height: Int, label: String? = nil) -> Int? {
        textureManager
            .makeTexture(ofWidth: width, height: height, label: label)
    }
   
    public func texture(byId id: Int) -> MTLTexture? {
        textureManager.texture(byId: id)
    }
    
    @MainActor
    public func makeRenderableView() -> TGRenderableView {
        TGRenderableView(graphics: self)
    }
 
    public func pushDebugGroup(_ name: String) {
        commandBuffer?.pushDebugGroup(name)
    }
    
    public func popDebugGroup() {
        commandBuffer?.popDebugGroup()
    }
  
    public func copy(texture inputTextureId: Int, on destinationTextureId: Int) {
        guard
            let inputTexture = textureManager.texture(byId: inputTextureId),
            let destinationTexture = textureManager.texture(byId: destinationTextureId),
            let commandBuffer
        else { return }
        renderer
            .copy(
                texture: inputTexture,
                on: destinationTexture,
                commandBuffer: commandBuffer
            )
    }
    
    public func substract(
        textureA textureAId: Int,
        textureB textureBId: Int,
        on outputTexture: Int
    ) {
        guard
            let textureA = textureManager.texture(byId: textureAId),
            let textureB = textureManager.texture(byId: textureBId),
            let outputTexture = textureManager.texture(byId: outputTexture),
            let commandBuffer
        else { return }
        renderer.substract(
            textureA: textureA,
            textureB: textureB,
            on: outputTexture,
            commandBuffer: commandBuffer
        )
    }
    
    public func colorize(
        grayscaleTexture textureId: Int,
        withColor color: simd_float4,
        on outputTextureId: Int
    ) {
        guard
            let commandBuffer,
            let grayscaleTexture = textureManager.texture(byId: textureId),
            let outputTexture = textureManager.texture(byId: outputTextureId)
        else { return }
        renderer.colorize(
            grayscaleTexture: grayscaleTexture,
            withColor: color,
            on: outputTexture,
            using: commandBuffer
        )
    }
    
    public func colorize(
        grayscaleTexture texture: TGTiledTexture,
        withColor color: simd_float4,
        on outputTexture: TGTiledTexture,
        dirtyTiles: Set<Int>
    ) {
        guard let commandBuffer else { return }
        renderer.colorize(
            grayscaleTexture: texture,
            withColor: color,
            on: outputTexture,
            dirtyTiles: dirtyTiles,
            textureManager: textureManager,
            using: commandBuffer
        )
    }
    
    public func drawGrayscalePoints(
        _ points: [TGRenderablePoint],
        in tiledTexture: TGTiledTexture,
        dirtyTiles: Set<Int>,
        tileSize: simd_float2,
        canvasSize: simd_long2,
        opacity: Float,
        shapeTextureId: Int = -1,
        transform: simd_float4x4,
        clearBackground: Bool = false
    ) {
        guard
             let commandBuffer
         else { return }
        
        guard
            let shapeTexture = textureManager.texture(byId: 0),
            let granuralityTexture = textureManager.texture(byId: 1)
        else { return }
        
        // TODO: create one buffer for any drawing operation
        guard let positionsBuffer = TGDevice.device.makeBuffer(
           bytes: points,
           length: MemoryLayout<TGRenderablePoint>.stride * points.count
        ) else { return }
       
        for index in dirtyTiles {
            let row = index / 8
            let col = index % 8
            
            var matrix = matrix_identity_float4x4
            matrix *= .init(scaledBy: [1, -1, 0])
            matrix *= .init(translateBy: [Float(canvasSize.x) / 2, Float(canvasSize.y) / 2, 0])
            matrix *= .init(translateBy: [-Float(col) * tileSize.x, -Float(row) * tileSize.y, 0])
            matrix *= .init(translateBy: [-tileSize.x / 2, -tileSize.y / 2, 0])
            matrix *= .init(scaledBy: [1, -1, 0])
            var transform = transform
            transform = matrix * transform

            if let texture = textureManager.texture(byId: tiledTexture.tiles[index].textureId) {
                let viewSize = Double(texture.height)
                let aspect = Double(texture.width) / Double(texture.height)
                let rect = CGRect(
                    x: Double(-viewSize * aspect) * 0.5,
                    y: Double(viewSize) * 0.5,
                    width: Double(viewSize * aspect),
                    height: Double(viewSize))
                
                let projectionMatrix = simd_float4x4(
                    ortho: rect,
                    near: 0,
                    far: 1
                )

                renderer.drawGrayscalePoints(
                    positionsBuffer: positionsBuffer,
                    numPoints: points.count,
                    withOpacity: opacity,
                    on: texture,
                    shapeTexture: shapeTexture,
                    granularityTexture: granuralityTexture,
                    transform: transform,
                    projection: projectionMatrix,
                    using: commandBuffer,
                    clearingBackground: false
                )
            }
        }
    }
    
    public func drawGrayscalePoints(
        _ drawablePoints: [TGRenderablePoint],
        numPoints: Int,
        in textureId: Int,
        opacity: Float,
        shapeTextureId: Int = -1,
        transform: simd_float4x4,
        projection: simd_float4x4,
        clearBackground: Bool = false
    ) {
       guard
            let commandBuffer,
            let texture = textureManager.texture(byId: textureId),
            let positionsBuffer = TGDevice.device.makeBuffer(
                bytes: drawablePoints,
                length: MemoryLayout<TGRenderablePoint>.stride * numPoints
            )
        else { return }
        // TODO: get shape/granurality textures form texture id param
        guard
            let shapeTexture = textureManager.texture(byId: 0),
            let granuralityTexture = textureManager.texture(byId: 1)
        else { return }
        renderer
            .drawGrayscalePoints(
                positionsBuffer: positionsBuffer,
                numPoints: numPoints,
                withOpacity: opacity,
                on: texture,
                shapeTexture: shapeTexture,
                granularityTexture: granuralityTexture,
                transform: transform,
                projection: projection,
                using: commandBuffer,
                clearingBackground: clearBackground
            )
    }
    
    public func fillTexture(_ textureId: Int, with color: simd_float4) {
        guard
            let texture = textureManager.texture(byId: textureId),
            let commandBuffer
        else { return }
        renderer.fillTexture(texture: texture, with: color, using: commandBuffer)
    }
    
    public func fillTexture(
        _ tiledTexture: TGTiledTexture,
        dirtyTiles: Set<Int>? = nil,
        color: simd_float4
    ) {
        // la logica esta al reves
        guard let commandBuffer else { return }
        if let dirtyTiles {
            for index in dirtyTiles {
                let tile = tiledTexture.tiles[index]
                if let texture = textureManager.texture(byId: tile.textureId) {
                    renderer.fillTexture(
                        texture: texture,
                        with: color,
                        using: commandBuffer
                    )
                }
            }
        } else {
            for index in 0..<tiledTexture.tiles.count {
                let tile = tiledTexture.tiles[index]
                if let texture = textureManager.texture(byId: tile.textureId) {
                    renderer.fillTexture(
                        texture: texture,
                        with: color,
                        using: commandBuffer
                    )
                }
            }
        }
    }
    
    public func merge(
        _ sourceTextureId: Int,
        with secondTextureId: Int,
        on destinationTextureId: Int
    ) {
        guard
            let sourceTexture = textureManager.texture(byId: sourceTextureId),
            let secondTexture = textureManager.texture(byId: secondTextureId),
            let destinationTexture = textureManager.texture(byId: destinationTextureId),
            let commandBuffer
        else {
            return
        }
        renderer
            .merge(
                sourceTexture,
                with: secondTexture,
                on: destinationTexture,
                using: commandBuffer
            )
    }
    
    public func drawTexture(
        _ tiledTexture: TGTiledTexture,
        on drawable: CAMetalDrawable,
        clearColor: simd_float4,
        transform: simd_float4x4,
        projection: simd_float4x4
    ) {
        guard let commandBuffer else { return }
        renderer.drawTiledTexture(
            tiledTexture,
            on: drawable.texture,
            using: commandBuffer,
            textureManager: textureManager,
            clearColor: clearColor,
            transform: transform,
            projection: projection
        )
    }
    
    // I don't like have this `CAMetalDrawable` as parameter.
    public func drawTexture(
        _ textureId: Int,
        on drawable: CAMetalDrawable,
        clearColor: simd_float4,
        transform: simd_float4x4,
        projection: simd_float4x4
    ) {
        guard
            let drawableTexture = textureManager.texture(byId: textureId),
            let commandBuffer
        else {
            return
        }
        renderer.drawTexture(
            drawableTexture,
            on: drawable.texture,
            using: commandBuffer,
            clearColor: clearColor,
            transform: transform,
            projection: projection
        )
    }
    
    func reset() {
        commandBuffer = TGDevice.commandQueue.makeCommandBuffer()
    }
    
    func present(_ drawable: CAMetalDrawable) {
        commandBuffer?.present(drawable)
    }
    
    func commit() {
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
    }
}
