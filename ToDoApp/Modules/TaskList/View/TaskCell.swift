//
//  TaskCell.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import UIKit

struct TaskCellViewModel {
    let title: String
    let description: String
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
    
    private lazy var statusIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
    
    // MARK: - Init
    
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
            statusIcon.image = UIImage(systemName: "checkmark.circle")
            statusIcon.tintColor = .accentPrimary
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = model.title
            titleLabel.textColor = .textPrimary
            descriptionLabel.textColor = .textPrimary
            statusIcon.image = UIImage(systemName: "circle")
            statusIcon.tintColor = .textSecondary
        }
    }
    
}

// MARK: - Private Methods

private extension TaskCell {
    
    func setupCell() {
        [statusIcon, titleLabel, descriptionLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            statusIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 8),
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
