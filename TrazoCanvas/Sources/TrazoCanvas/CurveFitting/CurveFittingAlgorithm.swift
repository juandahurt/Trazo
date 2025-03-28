//
//  CurveFittingAlgorithm.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 27/03/25.
//

protocol CurveFittingAlgorithm {
    associatedtype AnchorPoints
    func generateDrawablePoints(anchorPoints: AnchorPoints, scale: Float) -> [DrawablePoint]
}
