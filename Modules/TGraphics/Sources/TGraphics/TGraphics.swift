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
    
    public func makeTexture(ofSize size: simd_long2, label: String? = nil) -> Int? {
        textureManager.makeTexture(ofSize: size, label: label)
    }
   
    public func texture(byId id: Int) -> MTLTexture? {
        textureManager.texture(byId: id)
    }
    
    @MainActor
    public func makeRenderableView() -> TGRenderableView {
        TGRenderableView(graphics: self)
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
    
    public func drawGrayscalePoints(
        _ drawablePoints: [TGRenderablePoint],
        numPoints: Int,
        in textureId: Int,
        transform: simd_float4x4,
        projection: simd_float4x4
    ) {
       guard
            let commandBuffer,
            let texture = textureManager.texture(byId: textureId),
            let positionsBuffer = TGDevice.device.makeBuffer(
                bytes: drawablePoints,
                length: MemoryLayout<TGRenderablePoint>.stride * numPoints
            )
        else { return }
        renderer
            .drawGrayscalePoints(
                positionsBuffer: positionsBuffer,
                numPoints: numPoints,
                withOpacity: 1,
                on: texture,
                transform: transform,
                projection: projection,
                using: commandBuffer,
                clearingBackground: false
            )
    }
    
    public func fillTexture(_ textureId: Int, with color: simd_float4) {
        guard
            let texture = textureManager.texture(byId: textureId),
            let commandBuffer
        else { return }
        renderer.fillTexture(texture: texture, with: color, using: commandBuffer)
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
