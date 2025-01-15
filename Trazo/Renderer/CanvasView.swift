//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

struct Brush {
    var textureName: String
    var texture: MTLTexture?
    
    mutating func load(using device: MTLDevice) {
        let textureLoader = MTKTextureLoader(device: device)
        
        guard let url = Bundle.main.url(
            forResource: textureName,
            withExtension: "png"
        ) else {
            return
        }
        texture = try? textureLoader.newTexture(URL: url)
    }
}

struct RendererSettings {
    static let pixelFormat = MTLPixelFormat.rgba8Unorm
}

struct Line {
    var points: [Point]
}

class CanvasView: MTKView {
    let renderer = Renderer()
    let desiredDistance: Float = 2
    let brushSize: Float = 10.0
    
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
    func computePointScale(givenAForceOf force: Float) -> Float {
        guard force != 0 else { return brushSize }
        return brushSize * force
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: check if I need to do something if user uses more than one finger
        guard let touch = touches.first else { return }
        let cgPoint = touch.location(in: self)
        renderer.addLine(.init(points: [
            .init(
                scale: computePointScale(givenAForceOf: Float(touch.force)),
                position: [
                    Float(cgPoint.x) * Float(contentScaleFactor),
                    Float(cgPoint.y) * Float(contentScaleFactor)
                ]
            )
        ]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else { return }
        guard let lastPoint = renderer.lines[renderer.lines.count - 1].points.last else {
            return
        }
        guard let touch = touches.first else { return }

        let cgPoint = touch.location(in: self)
        var point = Point(
            scale: computePointScale(givenAForceOf: Float(touch.force)),
            position: [
                Float(cgPoint.x) * Float(contentScaleFactor),
                Float(cgPoint.y) * Float(contentScaleFactor)
            ]
        )
        
        let dist = distance(point.position, lastPoint.position)
        let dir = normalize(point.position - lastPoint.position)
        if dist > desiredDistance {
            // get the number of points that can fit in the space
            let numOfPoints = Int(dist / desiredDistance)
            // add more points in the space
            var lastAddedPoint: simd_float2?
            let lastScale = lastPoint.scale
            let scaleDiff = point.scale - lastScale
            let step = scaleDiff / Float(numOfPoints)
            
            for i in 0...numOfPoints {
                let newPointPos = lastPoint.position + (dir * desiredDistance * Float(i))
                addPointToLine(
                    .init(
                        scale: lastScale + (step * Float(i)),
                        position: newPointPos
                    )
                )
                lastAddedPoint = newPointPos
            }
            if let lastAddedPoint {
                point.position = lastAddedPoint + dir * desiredDistance
                addPointToLine(point)
            }
        } else if dist < desiredDistance {
            point.position = lastPoint.position + dir * desiredDistance
            addPointToLine(point)
        }
    }
    
    func addPointToLine(_ point: Point) {
//        renderer.lines[renderer.lines.count - 1].points.append(point)
        renderer.addPoint(point)
    }
}
