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
    func testEquality(a: Vector, b: Vector, actuallyEqual: Bool) {
        let areEqual = a == b
        #expect(areEqual == actuallyEqual)
    }
}
