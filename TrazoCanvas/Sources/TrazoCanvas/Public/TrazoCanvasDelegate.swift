//
//  TrazoCanvasDelegate.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 13/04/25.
//

@MainActor
public protocol TrazoCanvasDelegate: AnyObject {
    func canvas(_ canvas: TrazoCanvas, didLoadLayers layers: [TrazoLayer])
    func canvas(
        _ canvas: TrazoCanvas,
        didUpdateLayer layer: TrazoLayer,
        atIndex index: Int
    )
}
