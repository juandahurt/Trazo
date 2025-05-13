//
//  UIView+addBlur.swift
//  Trazo
//
//  Created by apolo on 13/05/25.
//

import UIKit

extension UIView {
    func addBlur() {
        let blur = UIBlurEffect(style: .systemMaterialDark)
        let visualEffect = UIVisualEffectView(effect: blur)
        visualEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(visualEffect)
    }
}
