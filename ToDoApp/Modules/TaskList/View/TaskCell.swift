//
//  TaskCell.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import UIKit

struct TaskCellViewModel {
    let title: String
    let description: String?
    let formattedDate: String
    let isCompleted: Bool
    
    init(_ task: Task) {
        self.title = task.title
        self.description = task.description
        self.formattedDate = task.createdAt.dateString
        self.isCompleted = task.isCompleted
    }
}

final class TaskCell: UITableViewCell {
    
    // MARK: - Subviews
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapStatusButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .textPrimary
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Static Properties

    static let reuseIdentifier = "TaskCell"
    
    // MARK: - Internal Properties
    
    var onCompleteButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Internal Methods

extension TaskCell {
    
    func configure(with model: TaskCellViewModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        dateLabel.text = model.formattedDate
        
        if model.isCompleted {
            let attributed = NSAttributedString(
                string: model.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                             .foregroundColor: UIColor.textSecondary])
            titleLabel.attributedText = attributed
            descriptionLabel.textColor = .textSecondary
            completeButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            completeButton.tintColor = .accentPrimary
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = model.title
            titleLabel.textColor = .textPrimary
            descriptionLabel.textColor = .textPrimary
            completeButton.setImage(UIImage(systemName: "circle"), for: .normal)
            completeButton.tintColor = .textSecondary
        }
    }
    
}

// MARK: - Private Methods

private extension TaskCell {
    
    func setupCell() {
        [completeButton, titleLabel, descriptionLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            completeButton.widthAnchor.constraint(equalToConstant: 24),
            completeButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
}

// MARK: - Actions

@objc
private extension TaskCell {
    
    func didTapStatusButton() {
        onCompleteButtonTapped?()
    }
    
}
