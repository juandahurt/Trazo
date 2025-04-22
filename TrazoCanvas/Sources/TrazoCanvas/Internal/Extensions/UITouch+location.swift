//
//  UITouch+location.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore
import UIKit

extension UITouch {
    func locationRelativeToCenter(ofView view: UIView) -> Vector2 {
        let cgLocation = location(in: view)
        var location = Vector2(
            Float(cgLocation.x),
            Float(cgLocation.y)
        )
        let canvasSize = Vector2(
            x: Float(view.bounds.width),
            y: Float(view.bounds.height)
        ) * Float(view.contentScaleFactor)
        
        location *= Float(view.contentScaleFactor)
        location.x -= Float(canvasSize.x) / 2
        location.y -= Float(canvasSize.y) / 2
        location.y *= -1
        
        return Vector2(location)
    }
}
