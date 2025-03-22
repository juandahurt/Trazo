//
//  ViewModel.swift
//  Trazo
//
//  Created by Juan Hurtado on 28/01/25.
//

import Combine
import UIKit
import TrazoCanvas

@MainActor
class ViewModel {
    private var canvas = TrazoCanvas()
    
    /// Publishes the canvas view when it has been created
    let canvasViewSubject = PassthroughSubject<UIView, Never>()
    
    func viewDidLoad() {
        let canvasView = canvas.makeCanvas()
        canvasViewSubject.send(canvasView)
    }
}
