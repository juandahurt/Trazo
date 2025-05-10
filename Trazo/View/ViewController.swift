//
//  ViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

import Combine
import UIKit

class ViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    private var topBarView = TopBarView()
   
    private let layersViewController: LayersViewController
    private var viewModel: ViewModel

    required init?(coder: NSCoder) {
        viewModel = ViewModel()
        let layersViewModel = LayersViewModel()
        layersViewModel.observer = viewModel
        viewModel.observer = layersViewModel
        layersViewController = .init(viewModel: layersViewModel)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
        
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        viewModel.viewDidLayoutSubviews()
    }
    
    private func setupSubviews() {
        addTopBarView()
        addCanvasView()
        
        addBrushSizeSlider()
    }
   
    func addCanvasView() {
        let canvasView = viewModel.canvasView
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addTopBarView() {
        topBarView.delegate = self
        view.addSubview(topBarView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topBarView.topAnchor),
            view.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func addBrushSizeSlider() {
        let slider = Slider()
        slider.minimumValue = CGFloat(viewModel.minBrushSize)
        slider.maximumValue = CGFloat(viewModel.maxBrushSize)
        slider.initialValue = CGFloat(viewModel.initialBrushSize)
        slider.addTarget(
            self,
            action: #selector(onBrushSizeSliderChange(_:)),
            for: .valueChanged
        )
        view.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slider.widthAnchor.constraint(equalToConstant: 45),
            slider.heightAnchor.constraint(equalToConstant: 200),
            slider.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc
    func onBrushSizeSliderChange(_ sender: Slider) {
        viewModel.didBrushSizeChange(Float(sender.value))
    }
}

extension ViewController: TopBarViewDelegate {
    func topBarViewDidRequestPresentingViewControllerForColorPicker(
        _ topBarView: TopBarView
    ) -> UIViewController {
        self
    }
    
    func topBarView(_ TopBarView: TopBarView, didSelect color: UIColor) {
        viewModel.didSelectColor(color)
    }
    
    func topBarViewDidSelectLayers(_ TopBarView: TopBarView) {
        layersViewController.modalPresentationStyle = .popover
        layersViewController.popoverPresentationController?.sourceRect = TopBarView.layersItemView.bounds
        layersViewController.popoverPresentationController?.sourceView = TopBarView.layersItemView
        present(layersViewController, animated: false)
    }
}
