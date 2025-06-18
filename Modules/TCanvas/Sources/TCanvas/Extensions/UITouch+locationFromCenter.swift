import simd
import UIKit

extension UITouch {
    func location(fromCenterOfView view: UIView) -> simd_float2 {
        let cgLocation = location(in: view)
        var location = simd_float2(
            Float(cgLocation.x),
            Float(cgLocation.y)
        )
        let canvasSize = simd_float2(
            x: Float(view.bounds.width),
            y: Float(view.bounds.height)
        ) * Float(view.contentScaleFactor)
        
        location *= Float(view.contentScaleFactor)
        location.x -= Float(canvasSize.x) / 2
        location.y -= Float(canvasSize.y) / 2
        location.y *= -1
        
        return simd_float2(location)
    }
}
