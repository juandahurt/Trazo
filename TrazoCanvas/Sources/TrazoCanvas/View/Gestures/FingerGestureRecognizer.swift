//
//  FingerGestureRecognizer.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 19/03/25.
//

import UIKit

@MainActor
protocol FingerGestureRecognizerDelegate: AnyObject {
    func didReceiveFingerTouches(_ touches: Set<UITouch>)
}

class FingerGestureRecognizer: UIGestureRecognizer {
    weak var fingerGestureDelegate: FingerGestureRecognizerDelegate?
    
    init() {
        super.init(target: nil, action: nil)
        
        allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        fingerGestureDelegate?.didReceiveFingerTouches(touches)
    }
}
