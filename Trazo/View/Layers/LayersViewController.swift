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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
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
        
        setupTitleLabel()
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
    
    func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.text = "Layers"
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
        ])
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
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
