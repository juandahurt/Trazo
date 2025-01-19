//
//  TouchHandler.swift
//  Trazo
//
//  Created by Juan Hurtado on 17/01/25.
//

import UIKit

protocol TouchHandler {
    func touchBegan(touch: UITouch)
    func touchMoved(touch: UITouch)
    func touchEnded()
}
