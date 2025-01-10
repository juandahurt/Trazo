//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

struct RendererSettings {
    static let pixelFormat = MTLPixelFormat.rgba8Unorm
}

struct Line {
    var points: [simd_float2]
}

class CanvasView: MTKView {
    let renderer = Renderer()
    let desiredDistance: Float = 2
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU unavailable")
        }
        super.init(frame: .zero, device: device)
        
        colorPixelFormat = RendererSettings.pixelFormat
        clearColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        
        delegate = renderer
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CanvasView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: check if I need to do something if user uses more than one finger
        guard let touch = touches.first else { return }
        let cgPoint = touch.location(in: self)
        renderer.addLine(.init(points: [
            .init(x: cgPoint.x, y: cgPoint.y)
        ]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let lastPoint = renderer.lines[renderer.lines.count - 1].points.last else {
            return
        }
        guard let touch = touches.first else { return }
        let cgPoint = touch.location(in: self)
        var point = simd_float2(x: cgPoint.x, y: cgPoint.y)
        
        let dist = distance(point, lastPoint)
        let dir = normalize(point - lastPoint)
        if dist > desiredDistance {
            // get the number of points that can fit in the space
            let numOfPoints = Int(dist / desiredDistance)
            // add more points in the space
            var lastAddedPoint: simd_float2?
            for i in 0...numOfPoints {
                let newPoint = lastPoint + (dir * desiredDistance * Float(i))
                addPointToLine(newPoint)
                lastAddedPoint = newPoint
            }
            if let lastAddedPoint {
                point = lastAddedPoint + dir * desiredDistance
                addPointToLine(point)
            }
        } else if dist < desiredDistance {
            point = lastPoint + dir * desiredDistance
            addPointToLine(point)
        }
    }
    
    func addPointToLine(_ point: simd_float2) {
        renderer.lines[renderer.lines.count - 1].points.append(point)
    }
}

extension simd_float2 {
    init(x: CGFloat, y: CGFloat) {
        self.init(x: Float(x), y: Float(y))
    }
}
