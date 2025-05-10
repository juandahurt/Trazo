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
    
    private var toolbarView = ToolbarView()
   
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
        addToolbarView()
        addCanvasView()
        
        addBrushSizeSlider()
    }
   
    func addCanvasView() {
        let canvasView = viewModel.canvasView
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addToolbarView() {
        toolbarView.delegate = self
        view.addSubview(toolbarView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: toolbarView.topAnchor),
            view.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 50)
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

extension ViewController: ToolbarViewDelegate {
    func toolbarViewDidRequestPresentingViewControllerForColorPicker(
        _ toolbarView: ToolbarView
    ) -> UIViewController {
        self
    }
    
    func toolbarView(_ toolbarView: ToolbarView, didSelect color: UIColor) {
        viewModel.didSelectColor(color)
    }
    
    func toolbarViewDidSelectLayers(_ toolbarView: ToolbarView) {
        layersViewController.modalPresentationStyle = .popover
        layersViewController.popoverPresentationController?.sourceRect = toolbarView.layersItemView.bounds
        layersViewController.popoverPresentationController?.sourceView = toolbarView.layersItemView
        present(layersViewController, animated: false)
    }
}
