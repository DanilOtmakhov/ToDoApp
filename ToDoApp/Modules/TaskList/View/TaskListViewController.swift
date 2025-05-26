//
//  TaskListViewController.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    func applyUpdate(_ update: TaskStoreUpdate)
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
    
    // MARK: - Internal Properties
    
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
        setupNavigationBar()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

// MARK: - Internal Methods

extension TaskListViewController {
    
    func applyUpdate(_ update: TaskStoreUpdate) {
        footerView.count = presenter.numberOfTasks
        
        tableView.performBatchUpdates {
            for change in update.changes {
                switch change {
                case .insert(let indexPath):
                    tableView.insertRows(at: [indexPath], with: .automatic)
                case .delete(let indexPath):
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                case .move(let from, let to):
                    tableView.moveRow(at: from, to: to)
                case .update(let indexPath):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
}

// MARK: - Private Methods

private extension TaskListViewController {
    
    func setupViewController() {
        view.backgroundColor = .background
        
        footerView.onAddButtonTapped = { [weak self] in
            self?.presenter.didTapAddTask()
        }
        
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
    
    func setupNavigationBar() {
        title = "Задачи"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.tintColor = .accentPrimary
        
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
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
            ) as? TaskCell,
            let task = presenter.task(at: indexPath.row)
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: task)
        cell.onCompleteButtonTapped = { [weak self] in
            self?.presenter.didTapCompleteButton(at: indexPath.row)
        }
        cell.onActionSelected = { [weak self] action in
            switch action {
            case .edit:
                self?.presenter.didTapEditTask(at: indexPath.row)
            case .share:
                self?.presenter.didTapShareTask(at: indexPath.row)
            case .delete:
                self?.presenter.didTapDeleteTask(at: indexPath.row)
            }
        }
        
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {
    
}
