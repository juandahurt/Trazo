//
//  CanvasManager.swift
//  Trazo
//
//  Created by Juan Hurtado on 17/01/25.
//

import UIKit
import simd

class CanvasManager {
    var renderer: Renderer
    var brushSize: Float = 10
    var currentBrush: Brush
    var lastAddedPoint: Point?
    var contentScaleFactor: Float = 1
    let desiredDistance: Float = 3
    weak var canvasView: CanvasView?
    
    init() {
        renderer = Renderer()
        currentBrush = .init(textureName: "default")
    }
    
    func setup(with canvasView: CanvasView) {
        canvasView.delegate = renderer
        self.canvasView = canvasView
        contentScaleFactor = Float(canvasView.contentScaleFactor)
    }
    
    private func location(of touch: UITouch) -> Vector {
        let cgPoint = touch.location(in: canvasView)
        return .init(
            x: Float(cgPoint.x) * contentScaleFactor,
            y: Float(cgPoint.y) * contentScaleFactor
        )
    }
    
    func computePointScale(givenAForceOf force: Float) -> Float {
        guard force != 0 else { return brushSize }
        return max(1, brushSize * force)
    }
}

extension CanvasManager: TouchHandler {
    func touchBegan(touch: UITouch) {
        let location = location(of: touch)
        let point = Point(
            scale: computePointScale(givenAForceOf: Float(touch.force)),
            position: location
        )
        renderer.addLine(.init(points: [point]))
        lastAddedPoint = point
    }
    
    func touchMoved(touch: UITouch) {
        guard var lastAddedPoint else { return }
        let location = location(of: touch)
        var point = Point(
            scale: computePointScale(givenAForceOf: Float(touch.force)),
            position: location
        )
        
        let dist = distance(point.position, lastAddedPoint.position)
        let dir = normalize(point.position - lastAddedPoint.position)
        if dist > desiredDistance {
            // get the number of points that can fit in the space
            let numOfPoints = Int(dist / desiredDistance)
            // add more points in the space
            var lastScale = lastAddedPoint.scale
            let scaleDiff = point.scale - lastScale
            let step = scaleDiff / Float(numOfPoints)
            
            for i in 0...numOfPoints {
                guard numOfPoints > 2 else { break }
                let newPointPos = lastAddedPoint.position + (
                    dir * desiredDistance * Float(i)
                )
                let newPoint = Point(
                    scale: lastScale + (step * Float(i)),
                    position: newPointPos
                )
                renderer.addPoint(newPoint)
            }
        }
        renderer.addPoint(point)
        self.lastAddedPoint = point
    }
    
    func touchEnded() {
        lastAddedPoint = nil
    }
}
