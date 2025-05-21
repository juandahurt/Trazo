//
//  LayersViewController.swift
//  Trazo
//
//  Created by Juan Hurtado on 14/04/25.
//

import Combine
import UIKit
import TrazoCanvas

typealias DataSource = UITableViewDiffableDataSource<LayerSection, LayerItem>
typealias Snapshot = NSDiffableDataSourceSnapshot<LayerSection, LayerItem>

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
    
    private lazy var dataSource: DataSource = makeDataSource()
    
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
        applySnapshot(viewModel.sections)
        view.layoutIfNeeded()
        preferredContentSize = tableView.contentSize
    }
    
    func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self]
            tableView,
            indexPath,
            itemIdentifier in
            guard let self else { return UITableViewCell() }
            
            if let item = itemIdentifier as? LayerTitleItem {
                guard
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "titleCell"
                    ) as? LayersTitleTableViewCell
                else {
                    return UITableViewCell()
                }
                cell.setup(using: item)
                return cell
            }
            
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "cell"
                ) as? LayersTableViewCell,
                let item = itemIdentifier as? LayerListItem
            else {
                return UITableViewCell()
            }
            
            cell.setup(using: item)
            cell.onVisibleButtonTap = { [weak self] in
                guard let self else { return }
                viewModel.intentToggleVisibilityOfLayer(atIndex: indexPath.row)
            }
            
            return cell
        }
    }
    
    func setupObservers() {
        viewModel.applySnapshotSubject.sink { [weak self] _ in
            guard let self else { return }
            applySnapshot(viewModel.sections)
        }.store(in: &disposeBag)
    }
   
    func applySnapshot(_ sections: [LayerSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.backgroundColor = .init(
            red: 0.2,
            green: 0.192,
            blue: 0.192,
            alpha: 1
        )
        tableView.separatorStyle = .none
        
        tableView.register(
            LayersTableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        tableView.register(
            LayersTitleTableViewCell.self,
            forCellReuseIdentifier: "titleCell"
        )
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
}

extension LayersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 40 }
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        viewModel.selectLayer(atIndex: indexPath.row)
    }
}
