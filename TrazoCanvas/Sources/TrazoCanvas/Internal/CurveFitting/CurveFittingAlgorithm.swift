//
//  CurveFittingAlgorithm.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 27/03/25.
//

import TrazoEngine

protocol CurveFittingAlgorithm {
    associatedtype AnchorPoints
    func generateDrawableSegment(
        anchorPoints: AnchorPoints,
        scale: Float,
        brushSize: Float,
        ignoreForce: Bool
    ) -> DrawableSegment
}
