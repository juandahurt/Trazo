//
//  DrawingWorkflow.swift
//  Trazo
//
//  Created by Juan Hurtado on 7/02/25.
//

import CoreGraphics

class CurveFittingStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        let curveNumPoints = state.currentCurve.numPoints
        guard curveNumPoints > 1 else { return }
        let p0 = state.currentCurve.points[curveNumPoints - 2]
        let p2 = state.currentCurve.points[curveNumPoints - 1]
        
        let tangent = p2 - p0
        
        let p1 = p0 + (0.7 * tangent) // control point
        
        let threshold = 0.5
        let distanceFromP0ToP2 = p0.distance(to: p2)
        guard distanceFromP0ToP2 > threshold else { return }
        let numPoints = Int(distanceFromP0ToP2 / threshold)
        
        for index in 0..<numPoints {
            let t = CGFloat(index) / CGFloat(numPoints)
            
            // cuadratic bezier parametric function
            let point: CGPoint = (1 - t) * ((1 - t) * p0 + (t * p1))
            + t * ((1 - t) * p1 + (t * p2))
            
            state.curveSectionToDraw.addPoint(point)
            state.currentCurve.addPoint(point)
        }
    }
}

class DrawingWorkflow: Workflow {
    override init() {
        super.init()
        steps = [
            InputProcessorStep(),
            CurveFittingStep(),
//            RemoveCurrentCurvePoints(),
            DrawGrayPointsStep(),
            DrawingStep(),
            CanvasPresentationStep()
        ]
    }
}


class RemoveCurrentCurvePoints: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
//        Renderer.instance
//            .substractTexture(
//                .init(metalTexture: state.drawingTexture!),
//                from: state.layerTexture!,
//                on: state.layerTexture!,
//                using: state.commandBuffer!
//            )
    }
}

class ClearStrokeTextureStep: WorkflowStep {
    override func excecute(using state: inout CanvasState) {
        Renderer.instance.fillTexture(
            texture: .init(metalTexture: state.strokeTexture!),
            with: (r: 0, g: 0, b: 0, a: 0),
            using: state.commandBuffer!
        )
    }
}
