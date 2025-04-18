//
//  LayersViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 14/04/25.
//

import Combine
import UIKit
import TrazoCanvas

class LayersViewController: UIViewController {
    let viewModel: LayersViewModel
    var disposeBag = Set<AnyCancellable>()
    
    let tableView = UITableView()
    
    init(viewModel: LayersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .init(
            red: 0.2,
            green: 0.192,
            blue: 0.192,
            alpha: 1
        )
        
        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        // TODO: find a way to prevent reloading all of the rows
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.viewDidDisappear()
    }
    
    func setupObservers() {
        viewModel.layerUpdateSubject.sink { [weak self] index in
            guard let self else { return }
            tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
        }.store(in: &disposeBag)
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.makeEgdes(equalTo: view)
        
        tableView.backgroundColor = .init(
            red: 0.2,
            green: 0.192,
            blue: 0.192,
            alpha: 1
        )
        
        tableView.register(
            LayersTableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension LayersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.layers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell"
            ) as? LayersTableViewCell
        else {
            return UITableViewCell()
        }
        
        cell.update(using: viewModel.layers[indexPath.row])
        cell.selectionStyle = .none
        cell.onVisibleButtonTap = { [weak self] in
            guard let self else { return }
            viewModel.intentToggleVisibilityOfLayer(atIndex: indexPath.row)
        }
        
        return cell
    }
}


extension LayersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
