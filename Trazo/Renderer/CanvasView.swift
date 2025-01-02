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
    var points: [CGPoint]
}

class CanvasView: MTKView {
    let renderer = Renderer()
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU unavailable")
        }
        super.init(frame: .zero, device: device)
        
        colorPixelFormat = RendererSettings.pixelFormat
        clearColor = .init(red: 0.1, green: 0.3, blue: 0.3, alpha: 1)
        
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
            convertToMetalCoordinates(point: cgPoint)
        ]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let cgPoint = touch.location(in: self)
        renderer.lines[renderer.lines.count - 1].points.append(
            convertToMetalCoordinates(point: cgPoint)
        )
    }
}

extension CanvasView {
    func convertToMetalCoordinates(point: CGPoint) -> CGPoint {
        let viewSize = bounds
        let inverseViewSize = CGSize(
            width: 1.0 / viewSize.width,
            height: 1.0 / viewSize.height
        )
        let clipX = (2.0 * point.x * inverseViewSize.width) - 1.0
        let clipY = (2.0 * -point.y * inverseViewSize.height) + 1.0
        return .init(x: clipX, y: clipY)
    }
}
