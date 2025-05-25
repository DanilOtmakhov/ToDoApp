//
//  TaskListViewController.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    func reloadData()
}

final class TaskListViewController: UIViewController, TaskListViewProtocol {
    
    // MARK: - Subviews
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var footerView: TaskListFooterView = TaskListFooterView()
    
    // MARK: - Private Properties
    
    var presenter: TaskListPresenterProtocol
    
    // MARK: - Initialization
    
    init(presenter: TaskListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.viewDidLoad()
    }

}

// MARK: - Internal Methods

extension TaskListViewController {
    
    func reloadData() {
        tableView.reloadData()
    }
    
}

// MARK: - Private Methods

private extension TaskListViewController {
    
    func setupViewController() {
        view.backgroundColor = .background
        title = "Задачи"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        [tableView, footerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/10)
        ])
    }
    
}

// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfTasks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskCell.reuseIdentifier,
                for: indexPath
            ) as? TaskCell
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: presenter.task(at: indexPath.row))
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {
    
}
