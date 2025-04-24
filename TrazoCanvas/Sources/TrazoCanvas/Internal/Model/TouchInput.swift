//
//  TouchInput.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 21/03/25.
//

// TODO: remove UIKit dependency
import UIKit
import TrazoCore

struct TouchInput {
    typealias ID = Int
    
    var id: ID
    var timestamp: TimeInterval
    var estimationUpdateIndex: NSNumber?
    var estimatedProperties: UITouch.Properties?
    var location: Vector2
    var phase: UITouch.Phase
}
