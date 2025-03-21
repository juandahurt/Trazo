//
//  TouchInput.swift
//  Trazo
//
//  Created by Juan Hurtado on 18/03/25.
//

import TrazoCore
import UIKit

struct Touch {
    typealias ID = Int
    
    var id: ID
    var location: vector_t
    var phase: UITouch.Phase
}
