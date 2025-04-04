//
//  UIColor+toVec4.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/03/25.
//

import UIKit
import TrazoCore

extension UIColor {
    func toVector4() -> Vector4 {
        guard
            let components = cgColor.components?.map({ Float($0) }),
            components.count == 4
        else { fatalError("Color components has a wrong format") }
        return [components[0], components[1], components[2], components[3]]
    }
}
