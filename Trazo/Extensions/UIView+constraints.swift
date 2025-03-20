//
//  UIView+constraints.swift
//  Trazo
//
//  Created by Juan Hurtado on 20/03/25.
//

import UIKit

extension UIView {
    func makeEgdes(equalTo view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
