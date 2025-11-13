public struct Transform {
    var a, b, c, d: Float
    var tx, ty: Float
    
    public var inverse: Transform {
        let det = a * d - c * b
        guard det != 0 else { return self }
        
        let invA = d / det
        let invB = -b / det
        let invC = -c / det
        let invD = a / det
        let invTx = -(invA * tx + invC * ty)
        let invTy = -(invB * tx + invD * ty)
        
        return .init(
            a: invA,
            b: invB,
            c: invC,
            d: invD,
            tx: invTx,
            ty: invTy
        )
    }
}

// MARK: - Multiplication
public extension Transform {
    func concatenating(_ other: Transform) -> Transform {
        Transform(
            a: a * other.a + c * other.b,
            b: b * other.a + d * other.b,
            c: a * other.c + c * other.d,
            d: b * other.c + d * other.d,
            tx: a * other.tx + c * other.ty + tx,
            ty: b * other.tx + d * other.ty + ty
        )
    }
}

// MARK: - Static properties
public extension Transform {
    nonisolated(unsafe)
    static let identity = Transform(
        a: 1,
        b: 0,
        c: 0,
        d: 1,
        tx: 0,
        ty: 0
    )
}
