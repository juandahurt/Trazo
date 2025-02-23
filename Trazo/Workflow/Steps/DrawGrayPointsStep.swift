//
//  DrawGrayPointsStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 17/02/25.
//


import simd

class DrawGrayPointsStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        guard state.curveSectionToDraw.numPoints > 0 else { return }
        let touchesPos: [simd_float2] = state.curveSectionToDraw.points.map {
            [Float($0.x), Float($0.y)]
        }
        // TODO: find a way to prevent creating a buffer per draw
        let positionsBuffer = Metal.device
            .makeBuffer(
                bytes: touchesPos,
                length: MemoryLayout<simd_float2>.stride * state.curveSectionToDraw.numPoints
            )
        
        state.commandBuffer?.pushDebugGroup("gray points on grayscale")
        // draw grayscale points
        Renderer.instance.drawGrayPoints(
            positionsBuffer: positionsBuffer!,
            numPoints: touchesPos.count,
            on: state.grayScaleTexture!,
            ctm: state.ctm.inverted(), // inverted bc the this texture is not really afected by the transformations
            using: state.commandBuffer!
        )
        state.commandBuffer?.popDebugGroup()
    }
}
