//import Metal
//
//struct Buffer {
//    let vertexBuffer: MTLBuffer
////    let textureBuffer: MTLBuffer
//    let indexBuffer: MTLBuffer
//    let indexCount: Int
//    
//    nonisolated(unsafe)
//    static let quad: Buffer = {
//        let vertices: [Float] = [
//            -0.5,  -0.5,
//             0.5,   -0.5,
//             -0.5,   0.5,
//             0.5,    0.5
//        ]
////        let textCoord: [Float] = [
////            0, 0,
////            1, 0,
////            0, 1,
////            1, 1
////        ]
//        let indices: [UInt16] = [
//            0, 1, 2,
//            1, 2, 3
//        ]
//        return Buffer(
//            vertexBuffer: GPU.device.makeBuffer(
//                bytes: vertices,
//                length: MemoryLayout<Float>.stride * vertices.count
//            )!,
////            textureBuffer: GPU.device.makeBuffer(
////                bytes: textCoord,
////                length: MemoryLayout<Float>.stride * textCoord.count,
////            )!,
//            indexBuffer: GPU.device.makeBuffer(
//                bytes: indices,
//                length: MemoryLayout<UInt16>.stride * indices.count,
//            )!,
//            indexCount: indices.count
//        )
//    }()
//}
