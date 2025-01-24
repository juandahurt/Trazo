//
//  PencilGestureRecognizer.swift
//  Trazo
//
//  Created by Juan Hurtado on 23/01/25.
//

import UIKit

protocol PencilGestureRecognizerDelegate: AnyObject {
    func onPencilEstimatedTouches(_ touches: Set<UITouch>)
    func onPencilActualTocuhes(_ touches: Set<UITouch>)
}

class PencilGestureRecognizer: UIGestureRecognizer {
    weak var pencilGestureDelegate: PencilGestureRecognizerDelegate?
    
    init() {
        super.init(target: nil, action: nil)
        self.allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.onPencilEstimatedTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.onPencilEstimatedTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.onPencilEstimatedTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        pencilGestureDelegate?.onPencilEstimatedTouches(touches)
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        pencilGestureDelegate?.onPencilActualTocuhes(touches)
    }
}
