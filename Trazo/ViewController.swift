//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import UIKit

class GridView: UIView {
    
    override func didMoveToSuperview() {
        backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawGrid(using: context)
    }
    
    func drawGrid(using context: CGContext) {
        let viewWidth = bounds.width
        let viewHeight = bounds.height
        let cellSize: CGFloat = 10
        
        let numCols = Int(viewWidth / cellSize)
        for col in 0...numCols {
            let x = CGFloat(col) * cellSize
            context.move(to: .init(x: x, y: 0))
            context.setStrokeColor(red: 37 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
            context.setLineWidth(1)
            context.addLine(to: .init(x: x, y: viewHeight))
        }
        
        let numRows = Int(viewHeight / cellSize)
        for row in 0...numRows {
            let y = CGFloat(row) * cellSize
            context.move(to: .init(x: 0, y: y))
            context.setStrokeColor(red: 37 / 255, green: 37 / 255, blue: 37 / 255, alpha: 1)
            context.setLineWidth(1)
            context.addLine(to: .init(x: viewWidth, y: y))
        }
        
        context.strokePath()
    }
}

class ViewController: UIViewController {
    private lazy var gridView: GridView = {
        let gridView = GridView()
        gridView.translatesAutoresizingMaskIntoConstraints = false
        return gridView
    }()
    
    private lazy var canvasView: CanvasView = {
        let canvasView = CanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        return canvasView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPinchGesture()
        addSubviews()
    }
    
    func addSubviews() {
        addGridView()
        addCanvasView()
    }
    
    func addGridView() {
        view.addSubview(gridView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: gridView.topAnchor),
            view.bottomAnchor.constraint(equalTo: gridView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: gridView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: gridView.trailingAnchor),
        ])
    }
    
    func addPinchGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(
            target: self,
            action: #selector(onPinchGesture(_:))
        )
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func addCanvasView() {
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate(
            [
                canvasView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor
                ),
                canvasView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor
                ),
                canvasView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor
                ),
                canvasView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor
                ),
            ]
        )
    }
}

extension ViewController {
    @objc
    func onPinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            canvasView.transform = canvasView.transform
                .scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
}
