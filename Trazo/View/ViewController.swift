//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import Combine
import UIKit

import TCanvas

class ViewController: UIViewController {
    let canvas = TCanvas()
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override func viewDidLoad() {
        canvas.load(in: view)
        
        view.backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
    }
}

//
//class ViewController: UIViewController {
//    override var prefersStatusBarHidden: Bool {
//        true
//    }
//    
//    private var topBarView = TopBarView()
//   
//    private let layersViewController: LayersViewController
//    private var viewModel: ViewModel
//
//    required init?(coder: NSCoder) {
//        viewModel = ViewModel()
//        let layersViewModel = LayersViewModel()
//        layersViewModel.observer = viewModel
//        viewModel.observer = layersViewModel
//        layersViewController = .init(viewModel: layersViewModel)
//        super.init(coder: coder)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
//        
//        setupSubviews()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        viewModel.viewDidLayoutSubviews()
//    }
//    
//    private func setupSubviews() {
//        addCanvasView()
//        addTopBarView()
//        
//        setupToolbar()
//    }
//   
//    func addCanvasView() {
//        let canvasView = viewModel.canvasView
//        view.addSubview(canvasView)
//        
//        NSLayoutConstraint.activate([
//            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
//            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    func addTopBarView() {
//        topBarView.delegate = self
//        view.addSubview(topBarView)
//        
//        NSLayoutConstraint.activate([
//            view.topAnchor.constraint(equalTo: topBarView.topAnchor),
//            view.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor),
//            topBarView.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//   
//    func setupToolbar() {
//        let toolbar = ToolbarView()
//        
//        view.addSubview(toolbar)
//        
//        NSLayoutConstraint.activate([
//            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            toolbar.widthAnchor.constraint(equalToConstant: 40),
//            toolbar.heightAnchor.constraint(equalToConstant: 450),
//            toolbar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        
//        toolbar.addSliderAttribute(
//            withValue: CGFloat(viewModel.initialBrushSize),
//            minimumValue: CGFloat(viewModel.minBrushSize),
//            maximumValue: CGFloat(viewModel.maxBrushSize),
//            imageName: "circle.fill"
//        ) { [weak self] value in
//            guard let self else { return }
//            viewModel.didBrushSizeChange(Float(value))
//        }
//        
//        toolbar.addSliderAttribute(
//            withValue: CGFloat(viewModel.initialBrushOpacity),
//            minimumValue: 0,
//            maximumValue: 1,
//            imageName: "circle.tophalf.filled.inverse"
//        ) { [weak self] value in
//            guard let self else { return }
//            viewModel.didBrushOpacityChange(Float(value))
//        }
//    }
//}
//
//extension ViewController: TopBarViewDelegate {
//    func topBarViewDidRequestPresentingViewControllerForColorPicker(
//        _ topBarView: TopBarView
//    ) -> UIViewController {
//        self
//    }
//    
//    func topBarView(_ TopBarView: TopBarView, didSelect color: UIColor) {
//        viewModel.didSelectColor(color)
//    }
//    
//    func topBarViewDidSelectLayers(_ TopBarView: TopBarView) {
//        layersViewController.modalPresentationStyle = .popover
//        layersViewController.popoverPresentationController?.sourceRect = TopBarView.layersItemView.bounds
//        layersViewController.popoverPresentationController?.sourceView = TopBarView.layersItemView
//        present(layersViewController, animated: false)
//    }
//}
