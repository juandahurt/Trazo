//
//  TrazoCanvasDescriptor.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 28/03/25.
//

import TrazoCore

public struct TrazoCanvasDescriptor {
    var brushColor: Vector4
    var brushSize: Float
    var brushOpacity: Float
    
    public init(brushColor: Vector4, brushSize: Float, brushOpacity: Float) {
        self.brushColor = brushColor
        self.brushSize = brushSize
        self.brushOpacity = brushOpacity
    }
}
