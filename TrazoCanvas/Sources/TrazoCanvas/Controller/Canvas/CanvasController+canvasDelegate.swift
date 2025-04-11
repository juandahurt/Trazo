//
//  CanvasController+canvasDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 23/03/25.
//

import MetalKit
import TrazoCore
import TrazoEngine

extension CanvasController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let width = Float(size.width)
        let height = Float(size.height)
        let viewSize: Float = height
        let aspect = width / height
        let rect = CGRect(
            x: Double(-viewSize * aspect) * 0.5,
            y: Double(viewSize) * 0.5,
            width: Double(viewSize * aspect),
            height: Double(viewSize))
        
        state.cpm = Mat4x4(
            orthographic: rect,
            near: 0,
            far: 1
        )
        print("delegate: ", viewSize, aspect, width, height)
        canvasView?.setNeedsDisplay()
    }

    func draw(in view: MTKView) {
        guard let currentDrawable = view.currentDrawable else { return }
        
        TrazoEngine.drawTexture(
            state.renderableTexture,
            on: currentDrawable.texture,
            clearColor: [0.15, 0.15, 0.15, 1],
            transform: state.ctm,
            projection: state.cpm
        )
        
        TrazoEngine.present(currentDrawable)
        
        TrazoEngine.commit()
        TrazoEngine.reset()
    }
}
