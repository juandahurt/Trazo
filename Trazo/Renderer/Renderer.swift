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
    var numInstances: Int = 0
    
    override init() {
        super.init()
        setup()
    }
   
    func addLine(_ line: Line) {
        lines.append(line)
//        numInstances += line.points.count
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
        
        let indices: [UInt16] = [
            0, 1, 2,
            2, 3, 0
        ]
        let indexBuffer = view.device?.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
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
            
            let positionsBuffer = view.device?.makeBuffer(
                bytes: line.points,
                length: MemoryLayout<simd_float2>.stride * numInstances
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
