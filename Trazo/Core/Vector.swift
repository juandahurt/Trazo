//
//  Vector.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/01/25.
//

import Foundation

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
    
    static func *(vector: Vector, scalar: Float) -> Vector {
        .init(x: vector.x * scalar, y: vector.y * scalar)
    }
}


extension Vector {
    func lenght() -> Float {
        hypotf(x, y)
    }
    
    mutating func normalize() {
        let length = lenght()
        x /= length
        y /= length
    }
}
