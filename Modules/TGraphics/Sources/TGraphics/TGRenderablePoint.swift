import simd

public struct TGRenderablePoint {
    public let location: simd_float2
    let size: Float
    
    public init(location: simd_float2, size: Float) {
        self.location = location
        self.size = size
    }
}
