//
//  PencilGestureRecognizer.swift
//  TrazoCanvas
//
//  Created by Juan Hurtado on 22/04/25.
//

import UIKit

@MainActor
protocol PencilGestureRecognizerDelegate: AnyObject {
    func didReceiveEstimatedTouches(_ touches: Set<UITouch>)
}

class PencilGestureRecognizer: UIGestureRecognizer {
    weak var pencilGestureDelegate: PencilGestureRecognizerDelegate?
    
    init() {
        super.init(target: nil, action: nil)
        
        allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.didReceiveEstimatedTouches(touches)
    }
}
