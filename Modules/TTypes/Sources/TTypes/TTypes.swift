import simd
import UIKit

public struct TTTouch {
    public let id: Int
    public let location: simd_float2
    public let phase: UITouch.Phase
    
    public init(id: Int, location: simd_float2, phase: UITouch.Phase) {
        self.id = id
        self.location = location
        self.phase = phase
    }
}
