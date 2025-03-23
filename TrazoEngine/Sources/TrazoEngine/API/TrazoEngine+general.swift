//
//  TrazoEngine+general.swift
//  TrazoEngine
//
//  Created by Juan Hurtado on 23/03/25.
//

extension TrazoEngine {
    static func makeCommandBuffer() {
        commandBuffer = GPU.commandQueue.makeCommandBuffer()
    }
    
    /// Loads the engine.
    public static func load() {
        makeCommandBuffer()
        // TODO: load pipeline states
    }
    
    public static func reset() {
        makeCommandBuffer()
    }
}
