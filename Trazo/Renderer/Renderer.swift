//
//  Renderer.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

typealias Vector = simd_float2
typealias Mat4x4 = simd_float4x4

extension Mat4x4 {
    init(translation: Vector) {
        let matrix = float4x4(
            [            1,             0, 0, 0],
            [            0,             1, 0, 0],
            [            0,             0, 1, 0],
            [translation.x, translation.y, 0, 1]
        )
        self = matrix
    }
    
    init(orthographic rect: CGRect, near: Float, far: Float) {
        let left = Float(rect.origin.x)
        let right = Float(rect.origin.x + rect.width)
        let top = Float(rect.origin.y)
        let bottom = Float(rect.height)
        let X = simd_float4(2 / (right - left), 0, 0, 0)
        let Y = simd_float4(0, 2 / (top - bottom), 0, 0)
        let Z = simd_float4(0, 0, 1 / (far - near), 0)
        let W = simd_float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    init(scaling scale: Vector) {
        let matrix = float4x4(
            [scale.x,         0, 0, 0],
            [        0, scale.y, 0, 0],
            [        0,         0, 1, 0],
            [        0,         0, 0, 1]
        )
        self = matrix
    }
}

struct Point {
    var scale: Float
    var position: Vector = .zero
    var modelMatrix: Mat4x4 {
        .init(translation: position) * .init(
            scaling: [
                scale,
                scale
            ]
        )
    }
}

struct Uniforms {
    var projectionMatrix: Mat4x4 = matrix_identity_float4x4
    var modelMatrix: Mat4x4 = matrix_identity_float4x4
}

//struct Tile {
//    var position: Vector
//    var vertexBuffer: MTLBuffer?
//    var needsToBeRendered = false
//    
//    var modelMatrix: Mat4x4 {
//        .init(translation: position)
//    }
//}

class Renderer: NSObject, MTKViewDelegate {
    var commandQueue: MTLCommandQueue?
    var renderPipelineState: MTLRenderPipelineState?
  
    var lines: [Line] = []
    var numInstances: Int = 0
    
    var uniforms = Uniforms()
    
    let indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var modelMatricesBuffer: MTLBuffer?
    
//    let tileSize = 100
//    var tiles: [[Tile]] = []
    
    var brush = Brush(textureName: "default")
    
    var cols = 0
    var rows = 0
    
    var canvasTexture: MTLTexture?
    
    override init() {
        super.init()
        setup()
    }
    
    func convertToMetalCoordinates(point: Vector) -> Vector {
        let inverseViewSize = CGSize(
            width: 1.0 / Double(canvasWidth),
            height: 1.0 / Double(canvasHeight)
        )
        let clipX = (2.0 * CGFloat(point.x) * inverseViewSize.width) - 1.0
        let clipY = (2.0 * -CGFloat(point.y) * inverseViewSize.height) + 1.0
        return Vector(x: Float(clipX), y: Float(clipY))
    }
    
    func addLine(_ line: Line) {
        lines.append(line)
    }
    
    func addPoint(_ point: Point) {
        #warning("show point")
    }
    
    func setupCanvasTexture(with device: MTLDevice) {
        let descriptor = MTLTextureDescriptor
            .texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: canvasWidth,
                height: canvasHeight,
                mipmapped: false
            )
        descriptor.usage = [.renderTarget, .shaderRead]
        canvasTexture = device.makeTexture(descriptor: descriptor)
        
        guard let canvasTexture else {
            fatalError("couldn't create canvas texture")
            return
        }
        
        let rowBytes = 4 * canvasWidth
        let whiteData = [UInt8](repeating: 255, count: rowBytes * canvasHeight)
        whiteData.withUnsafeBytes { pointer in
            let region = MTLRegion(
                origin: .init(x: 0, y: 0, z: 0),
                size: .init(
                    width: canvasWidth,
                    height: canvasHeight,
                    depth: 1
                )
            )
            canvasTexture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: pointer.baseAddress!,
                bytesPerRow: rowBytes
            )
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: remove?
        let rect = CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height
        )
        let projection: Mat4x4 = .init(
            orthographic: rect,
            near: 0,
            far: 1
        )
        uniforms.projectionMatrix = projection
    }
    
    
    
    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue?.makeCommandBuffer()
        else {
            return
        }
        let encoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor
        )
        encoder?.setRenderPipelineState(renderPipelineState!)
        encoder?.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        
        encoder?.setFragmentTexture(canvasTexture, index: 3)
        
        encoder?
            .drawIndexedPrimitives(
                type: .triangle,
                indexCount: indices.count,
                indexType: .uint16,
                indexBuffer: indexBuffer!,
                indexBufferOffset: 0
            )
        
        encoder?.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}


extension Renderer {
    private func setup() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        
        brush.load(using: device)
        setupIndexBuffer(with: device)
        setupVertexBuffer(with: device)
        setupCanvasTexture(with: device)
        
        commandQueue = device.makeCommandQueue()
        
        guard let library = device.makeDefaultLibrary() else {
            fatalError("couldn't create library")
        }
        let vertexFunction = library.makeFunction(name: "vertex_shader")
        let fragmentFunction = library.makeFunction(name: "fragment_shader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float2>.stride
        
        vertexDescriptor
            .layouts[0].stride = MemoryLayout<simd_float2>.stride * 2
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = RendererSettings.pixelFormat
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor
            .colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .blendAlpha
        pipelineDescriptor
            .colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor
            )
        } catch {
            debugPrint(error)
        }
        
        
    }
    
    private func setupVertexBuffer(with device: MTLDevice) {
        let vertices: [simd_float4] = [
            [-1, -1, 0, 0],
            [-1, 1, 0, 1],
            [1, 1, 1, 1],
            [1, -1, 1, 0],
        ]
        
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<simd_float4>.stride * vertices.count
        )
    }

    private func setupIndexBuffer(with device: MTLDevice) {
        indexBuffer = device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
        )
    }
    
    private func setupModelMatricesBuffer(with device: MTLDevice) {
        let empty = [0]
        modelMatricesBuffer = device.makeBuffer(
            bytes: empty,
            length: device.maxBufferLength
        )
    }
}
