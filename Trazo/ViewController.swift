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
        let cellSize: CGFloat = 15
        
        let colorValue: CGFloat = 32 / 255
        let lineColor = CGColor(
            red: colorValue,
            green: colorValue,
            blue: colorValue,
            alpha: 1
        )
        
        context.setStrokeColor(lineColor)
        context.setLineWidth(1)
        
        let numCols = Int(viewWidth / cellSize)
        for col in 0...numCols {
            let x = CGFloat(col) * cellSize
            context.move(to: .init(x: x, y: 0))
            context.addLine(to: .init(x: x, y: viewHeight))
        }
        
        let numRows = Int(viewHeight / cellSize)
        for row in 0...numRows {
            let y = CGFloat(row) * cellSize
            context.move(to: .init(x: 0, y: y))
            context.addLine(to: .init(x: viewWidth, y: y))
        }
        
        context.strokePath()
    }
}


let canvasWidth: Int = 1000
let canvasHeight: Int = 1000

class ViewController: UIViewController {
    private lazy var gridView: GridView = {
        let gridView = GridView()
        gridView.translatesAutoresizingMaskIntoConstraints = false
        return gridView
    }()
    
    private lazy var canvasView: CanvasView = {
        let canvasView = CanvasView(frame: view.frame)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        let pencilGesture = PencilGestureRecognizer()
        pencilGesture.pencilGestureDelegate = self
        canvasView.addGestureRecognizer(pencilGesture)
        return canvasView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPinchGesture()
        addSubviews()
        
        canvasView.transform = canvasView.transform
            .scaledBy(x: 0.2, y: 0.2)
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
        
        NSLayoutConstraint.activate([
            canvasView.heightAnchor.constraint(equalToConstant: CGFloat(canvasHeight)),
            canvasView.widthAnchor.constraint(equalToConstant: CGFloat(canvasWidth)),
            canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            canvasView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    var touches: [UITouch] = []
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

extension ViewController: PencilGestureRecognizerDelegate {
    func onPencilEstimatedTouches(_ touches: Set<UITouch>) {
        // TODO: send estimated touches
    }
    
    func onPencilActualTocuhes(_ touches: Set<UITouch>) {
        // TODO: send actual touches
    }
}
