//
//  TrazoEngine+debug.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

public extension TrazoEngine {
    static func pushDebugGroup(_ name: String) {
        commandBuffer?.pushDebugGroup(name)
    }
    
    static func popDebugGroup() {
        commandBuffer?.popDebugGroup()
    }
}
