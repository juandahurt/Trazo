//
//  Metal.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

import Metal

@MainActor
struct Metal {
    static private var _device: MTLDevice?
    static var device: MTLDevice {
        if _device == nil {
            _device = MTLCreateSystemDefaultDevice()
            assert(_device != nil, "GPU isn't available.")
        }
        return _device!
    }
    
    static private var _defaultLibrary: MTLLibrary?
    static var defaultLibrary: MTLLibrary {
        if _defaultLibrary == nil {
            _defaultLibrary = device.makeDefaultLibrary()
            assert(_defaultLibrary != nil, "No Metal files found.")
        }
        return _defaultLibrary!
    }
    
    static private var _commandQueue: MTLCommandQueue?
    static var commandQueue: MTLCommandQueue {
        if _commandQueue == nil {
            _commandQueue = device.makeCommandQueue()
            assert(_commandQueue != nil, "Wtf?")
        }
        return _commandQueue!
    }
}
