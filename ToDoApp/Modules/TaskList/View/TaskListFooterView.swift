//
//  TaskListFooterView.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import UIKit

final class TaskListFooterView: UIView {
    
    // MARK: - Subviews
    
    private lazy var taskCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    private lazy var addButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .accentPrimary
        return button
    }()
    
    // MARK: - Internal Properties
    
    var count: Int = 0 {
        didSet { taskCountLabel.text = "\(count) Задач" }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Private Methods

private extension TaskListFooterView {
    
    func setupView() {
        backgroundColor = .backgroundGray
        
        [taskCountLabel, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            taskCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            taskCountLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20.5),
            
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: taskCountLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
}
