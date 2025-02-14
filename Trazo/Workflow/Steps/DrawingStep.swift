//
//  DrawingStep.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/02/25.
//

import simd
import CoreGraphics

class DrawingStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        print("executing drawing step")
        
        let touchesPos: [simd_float2] = [state.drawableTouch].map {
            [Float($0.positionInTextCoord.x), Float($0.positionInTextCoord.y)]
        }
        // TODO: find a way to prevent creating a buffer per draw
        let positionsBuffer = Metal.device
            .makeBuffer(
                bytes: touchesPos,
                length: MemoryLayout<simd_float2>.stride * touchesPos.count
            )
        
//        let ctm = state.ctm.scaledBy(x: state.currScale, y: state.currScale).inverted()
        // draw grayscale points
        Renderer.instance.drawGrayPoints(
            positionsBuffer: positionsBuffer!,
            numPoints: touchesPos.count,
            on: state.grayScaleTexture!,
            ctm: state.ctm.inverted(),
            using: state.commandBuffer!
        )
        
        // colorization
        Renderer.instance.colorize(
            grayscaleTexture: state.grayScaleTexture!,
            withColor: (0, 0, 0, 1),
            on: state.drawingTexture!,
            using: state.commandBuffer!
        )
        
        // merge drawing texture with the canvas texture
        Renderer.instance.merge(
            state.drawingTexture!,
            to: state.canvasTexture!.actualTexture,
            using: state.commandBuffer!
        )
        
        // make sure the background is not cleared on the presentation step
//        state.canvasBackgroundColor = nil
    }
    
    func removeScaling(from transform: CGAffineTransform) -> CGAffineTransform {
        // Extract scale components
        let scaleX = hypot(transform.a, transform.b)  // Scale along X-axis
        let scaleY = hypot(transform.c, transform.d)  // Scale along Y-axis
        
        // Normalize rotation components
        let newA = transform.a / scaleX
        let newB = transform.b / scaleX
        let newC = transform.c / scaleY
        let newD = transform.d / scaleY

        return CGAffineTransform(a: newA, b: newB, c: newC, d: newD, tx: transform.tx, ty: transform.ty)
    }
}

