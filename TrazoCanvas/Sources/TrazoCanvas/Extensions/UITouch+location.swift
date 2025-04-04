//
//  UITouch+location.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

import TrazoCore
import UIKit

extension UITouch {
    func location(inView view: UIView) -> Vector2 {
        let cgLocation = self.location(in: view)
        return Vector2(cgLocation)
    }
}
