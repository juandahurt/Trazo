//
//  VectorTests.swift
//  Trazo
//
//  Created by Juan Hurtado on 4/01/25.
//

@testable import Trazo
import Testing

struct VectorTests {
    @Test("Vector equality", arguments: [
        (Vector(x: 1, y: 2), Vector(x: 2, y: 4), false),
        (Vector(x: 81, y: 2), Vector(x: 2, y:-14), false),
        (Vector(x: 1, y: 1), Vector(x: 1, y: 1), true),
    ])
    func equality(a: Vector, b: Vector, actuallyEqual: Bool) {
        let areEqual = a == b
        #expect(areEqual == actuallyEqual)
    }
    
    @Test("Vector sum", arguments: [
        (Vector(x: 1, y: 10), Vector(x: 3, y: 2), Vector(x: 4, y: 12)),
        (Vector(x: -3, y: 1), Vector(x: -3, y: 10), Vector(x: -6, y: 11)),
    ])
    func sum(a: Vector, b: Vector, actualResult: Vector) {
        let sum = a + b
        #expect(sum == actualResult)
    }
    
    @Test("Vector sum", arguments: [
        (Vector(x: 1, y: 10), Vector(x: 3, y: 2), Vector(x: -2, y: 8)),
        (Vector(x: -3, y: 1), Vector(x: -3, y: 10), Vector(x: 0, y: -9)),
    ])
    func substraction(a: Vector, b: Vector, actualResult: Vector) {
        let sum = a - b
        #expect(sum == actualResult)
    }
}
