//
//  Renderer.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    var commandQueue: MTLCommandQueue?
    var renderPipelineState: MTLRenderPipelineState?
    
    var vertexBuffer: MTLBuffer?
    
    override init() {
        super.init()
        setup()
    }
   
    func convertToMetalCoordinates(point: CGPoint, viewSize: CGSize) -> simd_float4 {
        let inverseViewSize = CGSize(
            width: 1.0 / viewSize.width,
            height: 1.0 / viewSize.height
        )
        let clipX = Float((2.0 * point.x * inverseViewSize.width) - 1.0)
        let clipY = Float((2.0 * -point.y * inverseViewSize.height) + 1.0)
        return [clipX, clipY, 0, 1]
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: is this ever going to be called?
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
        
        var vertices: [simd_float2] = [
            [0.5, 0.5],
            [1, 1],
            [0.5, -0.5],
        ]
        vertexBuffer = view.device?.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<simd_float2>.stride * vertices.count
        )
        encoder?.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        encoder?
            .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
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
