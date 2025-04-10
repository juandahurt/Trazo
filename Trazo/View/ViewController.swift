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
    
    private lazy var _brushSizeSliderView: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = viewModel.minBrushSize
        slider.maximumValue = viewModel.maxBrushSize
        slider.value = viewModel.initialBrushSize
        slider.addTarget(self, action: #selector(onBrushSizeSliderChange(_:)), for: .valueChanged)
        return slider
    }()
    
    private var toolbarView = ToolbarView()
    
    private var viewModel = ViewModel()
    
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
            toolbarView.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    func addBrushSizeSlider() {
        view.addSubview(_brushSizeSliderView)
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(
                equalTo: _brushSizeSliderView.bottomAnchor,
                constant: 40
            ),
            view.centerXAnchor.constraint(
                equalTo: _brushSizeSliderView.centerXAnchor
            ),
            _brushSizeSliderView.widthAnchor.constraint(
                equalToConstant: 200
            )
        ])
    }
    
    @objc
    func onBrushSizeSliderChange(_ sender: UISlider) {
        viewModel.didBrushSizeChange(sender.value)
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
}
