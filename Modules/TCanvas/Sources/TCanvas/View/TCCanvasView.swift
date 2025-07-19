import Combine
import TGraphics
import TPainter
import TTypes
import UIKit

class TCCanvasView: UIView {
    let viewModel: TCViewModel
    var renderableView: TGRenderableView?
    
    var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: TCViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setupSubscriptions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(in view: UIView) {
        addCanvasView(in: view)
        setupRenderableView()
        guard let renderableView else { return }
        viewModel.load(using: renderableView, size: view.bounds.size)
    }
   
    private func setupSubscriptions() {
        viewModel.renderableViewNeedsDisplaySubject.sink { [weak self] _ in
            guard let self else { return }
            renderableView?.setNeedsDisplay()
        }.store(in: &disposeBag)
    }
    
    private func addCanvasView(in view: UIView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupRenderableView() {
        renderableView = viewModel.makeRenderableView()
        
        guard let renderableView else { return }
        
        renderableView.renderableDelegate = viewModel
        
        addSubview(renderableView)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: renderableView.topAnchor),
            leadingAnchor.constraint(equalTo: renderableView.leadingAnchor),
            trailingAnchor.constraint(equalTo: renderableView.trailingAnchor),
            bottomAnchor.constraint(equalTo: renderableView.bottomAnchor),
        ])
        
        // gestures
        let fingerGestureRecognizer = TCFingerGestureRecognizer()
        renderableView.addGestureRecognizer(fingerGestureRecognizer)
        fingerGestureRecognizer.fingerGestureDelegate = self
        
        let pencilGestureRecognizer = TCPencilGestureRecognizer()
        renderableView.addGestureRecognizer(pencilGestureRecognizer)
        pencilGestureRecognizer.pencilGestureDelegate = self
    }
}


extension TCCanvasView: TCFingerGestureRecognizerDelegate {
    func didReceiveFingerTouches(_ touches: Set<UITouch>) {
        guard let renderableView else { return }
        let touches = touches.map {
            TCTouch($0, view: renderableView)
        }
        viewModel.handleFingerTouches(touches)
    }
}

extension TCCanvasView: TCPencilGestureRecognizerDelegate {
    func didReceiveEstimatedPencilTouches(_ touches: Set<UITouch>) {
        guard let renderableView else { return }
        guard let uiTouch = touches.first else { return }
        let touch = TCTouch(uiTouch, view: renderableView)
        viewModel.onEstimatedPencilTouch(touch)
    }
    
    func didReceiveActualPencilTouches(_ touches: Set<UITouch>) {
        guard let uiTouch = touches.first else { return }
        guard let renderableView else { return }
        let touch = TCTouch(uiTouch, view: renderableView)
        viewModel.onActualPencilTouch(touch)
    }
}
