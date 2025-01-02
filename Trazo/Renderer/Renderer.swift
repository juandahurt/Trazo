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
    
    var lines: [Line] = []
    
    override init() {
        super.init()
        setup()
    }
   
    func addLine(_ line: Line) {
        lines.append(line)
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
       
        for line in lines {
            var vertices: [simd_float2] = line.points.map {
                [Float($0.x), Float($0.y)]
            }
            var vertexBuffer = view.device?.makeBuffer(
                bytes: vertices,
                length: MemoryLayout<simd_float2>.stride * vertices.count
            )
            encoder?.setVertexBuffer(
                vertexBuffer,
                offset: 0,
                index: 0
            )
            encoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
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
