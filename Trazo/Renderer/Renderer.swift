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
   
    var addedLines: [Line] = []
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
                convertToMetalCoordinates(point: $0, view: view)
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
            encoder?.setFragmentBytes(
                [0, 0, 0, 1],
                length: MemoryLayout<simd_half4>.stride,
                index: 10
            )
            
            encoder?
                .drawPrimitives(
                    type: .point,
                    vertexStart: 0,
                    vertexCount: vertices.count
                )
        }
        
        commandBuffer.present(drawable)
            
        encoder?.endEncoding()
        commandBuffer.commit()
    }
    
    func convertToMetalCoordinates(point: simd_float2, view: MTKView) -> simd_float2 {
        let viewSize = view.bounds
        let inverseViewSize = CGSize(
            width: 1.0 / viewSize.width,
            height: 1.0 / viewSize.height
        )
        let clipX = (2.0 * CGFloat(point.x) * inverseViewSize.width) - 1.0
        let clipY = (2.0 * CGFloat(-point.y) * inverseViewSize.height) + 1.0
        return .init(x: Float(clipX), y: Float(clipY))
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
