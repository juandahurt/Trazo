//
//  FingerGestureRecognizer.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import UIKit

protocol FingerGestureRecognizerDelegate: AnyObject {
    func onFingerTouch(_ touch: UITouch)
}

class FingerGestureRecognizer: UIGestureRecognizer {
    weak var fingerGestureDelegate: FingerGestureRecognizerDelegate?
    
    init() {
        super.init(target: nil, action: nil)
        
        allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        fingerGestureDelegate?.onFingerTouch(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        fingerGestureDelegate?.onFingerTouch(touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        fingerGestureDelegate?.onFingerTouch(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        fingerGestureDelegate?.onFingerTouch(touch)
    }
}
