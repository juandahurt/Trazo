//
//  Vector.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/01/25.
//

import CoreGraphics

struct Vector {
    var x: Float
    var y: Float
}

extension Vector {
    static func ==(lhs: Vector, rhs: Vector) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: Vector, rhs: Vector) -> Vector {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
