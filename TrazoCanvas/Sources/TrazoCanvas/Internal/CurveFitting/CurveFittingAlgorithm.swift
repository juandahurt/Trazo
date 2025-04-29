//
//  CurveFittingAlgorithm.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 27/03/25.
//

import TrazoEngine

protocol CurveFittingAlgorithm {
    associatedtype AnchorPoints
    func generateDrawablePoints(anchorPoints: AnchorPoints, scale: Float, brushSize: Float) -> [DrawablePoint]
}
