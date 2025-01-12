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
}

class Renderer: NSObject, MTKViewDelegate {
    var commandQueue: MTLCommandQueue?
    var renderPipelineState: MTLRenderPipelineState?
  
    var lines: [Line] = []
    var numInstances: Int = 0
    
    var uniforms = Uniforms()
    
    override init() {
        super.init()
        setup()
    }
   
    func addLine(_ line: Line) {
        lines.append(line)
//        numInstances += line.points.count
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
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
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 3, 0
        ]
        let indexBuffer = view.device?.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
        )
        
        encoder?.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: 2
        )
        
        if let line = lines.first {
            numInstances = line.points.count
            var vertices: [simd_float2] = [
                [-0.5, -0.5],
                [-0.5, 0.5],
                [0.5, 0.5],
                [0.5, -0.5],
            ]
            
            let vertexBuffer = view.device?.makeBuffer(
                bytes: vertices,
                length: MemoryLayout<simd_float2>.stride * vertices.count
            )
           
            encoder?.setVertexBuffer(
                vertexBuffer,
                offset: 0,
                index: 0
            )
            
            let positions = line.points.map {
                $0.modelMatrix
            }
            let positionsBuffer = view.device?.makeBuffer(
                bytes: positions,
                length: MemoryLayout<Mat4x4>.stride * numInstances
            )
            encoder?.setVertexBuffer(
                positionsBuffer,
                offset: 0,
                index: 1
            )
            
            encoder?
                .drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: indices.count,
                    indexType: .uint16,
                    indexBuffer: indexBuffer!,
                    indexBufferOffset: 0,
                    instanceCount: numInstances
                )
        }
        
        commandBuffer.present(drawable)
            
        encoder?.endEncoding()
        commandBuffer.commit()
    }
}


extension Renderer {
    private func setup() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        commandQueue = device.makeCommandQueue()
        
        guard let library = device.makeDefaultLibrary() else {
            fatalError("couldn't create library")
        }
        let vertexFunction = library.makeFunction(name: "vertex_shader")
        let fragmentFunction = library.makeFunction(name: "fragment_shader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<simd_float2>.stride
        
        let pipelineDesciptor = MTLRenderPipelineDescriptor()
        pipelineDesciptor.vertexFunction = vertexFunction
        pipelineDesciptor.colorAttachments[0].pixelFormat = RendererSettings.pixelFormat
        pipelineDesciptor.fragmentFunction = fragmentFunction
        pipelineDesciptor.vertexDescriptor = vertexDescriptor
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(
                descriptor: pipelineDesciptor
            )
        } catch {
            debugPrint(error)
        }
    }
}
