//
//  CGPoint+operands.swift
//  Trazo
//
//  Created by Juan Hurtado on 16/02/25.
//

import CoreGraphics
import simd

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }
    
    static func /(point: CGPoint, value: CGFloat) -> CGPoint {
        .init(
            x: point.x / value,
            y: point.y / value
        )
    }
    
    static func *(point: CGPoint, value: CGFloat) -> CGPoint {
        .init(
            x: point.x * value,
            y: point.y * value
        )
    }
    
    static func *(value: CGFloat, point: CGPoint) -> CGPoint {
        .init(
            x: point.x * value,
            y: point.y * value
        )
    }
    
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        simd.distance(simd_double2([x, y]), [point.x, point.y])
    }
}
