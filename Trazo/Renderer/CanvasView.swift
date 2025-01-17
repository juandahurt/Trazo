//
//  CanvasView.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import MetalKit

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
    let manager = CanvasManager()
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU unavailable")
        }
        super.init(frame: .zero, device: device)
        
        colorPixelFormat = RendererSettings.pixelFormat
        clearColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        manager.setup(with: self)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CanvasView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        manager.touchBegan(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        manager.touchMoved(touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else { return }
        guard let _ = touches.first else { return }
        manager.touchEnded()
    }
}
