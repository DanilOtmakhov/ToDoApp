//
//  TaskEditorViewController.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import UIKit

struct TaskEditorViewModel {
    let title: String?
    let description: String?
    let dateString: String?
    
    init(_ task: Task?) {
        self.title = task?.title
        self.description = task?.description
        self.dateString = task?.createdAt.dateString
    }
}

protocol TaskEditorViewProtocol: AnyObject {
    func reloadData(_ viewModel: TaskEditorViewModel)
    func focusTitleField()
}

final class TaskEditorViewController: UIViewController, TaskEditorViewProtocol {
    
    // MARK: - Subviews
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textColor = .textPrimary
        textField.font = .systemFont(ofSize: 34, weight: .bold)
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.textColor = .textPrimary
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    private var doneButton: UIBarButtonItem?
    
    // MARK: - Private Properties
    
    private let presenter: TaskEditorPresenterProtocol
    
    // MARK: - Initialization
    
    init(presenter: TaskEditorPresenterProtocol) {
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

}

// MARK: - Internal Methods

extension TaskEditorViewController {
    
    func reloadData(_ viewModel: TaskEditorViewModel) {
        titleTextField.text = viewModel.title
        dateLabel.text = viewModel.dateString
        descriptionTextView.text = viewModel.description
    }
    
    func focusTitleField() {
        titleTextField.becomeFirstResponder()
    }
    
}

// MARK: - Private Methods

private extension TaskEditorViewController {
    
    func setupViewController() {
        view.backgroundColor = .background
        
        [titleTextField, dateLabel, descriptionTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        doneButton = UIBarButtonItem(title: "Готово",
                                      style: .done,
                                      target: self,
                                      action: #selector(didTapDoneButton))
        doneButton?.isEnabled = true
        doneButton?.isAccessibilityElement = true
    }
    
    func updateDoneButtonVisibility() {
        let isTitleEmpty = titleTextField.text?.isEmpty ?? true
        navigationItem.rightBarButtonItem = isTitleEmpty ? nil : doneButton
    }
    
}

// MARK: - Actions

@objc
private extension TaskEditorViewController {
    
    func didTapDoneButton() {
        presenter.didTapDone(title: titleTextField.text, description: descriptionTextView.text)
        navigationItem.rightBarButtonItem = nil
    }
    
}

// MARK: - UITextFieldDelegate

extension TaskEditorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateDoneButtonVisibility()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateDoneButtonVisibility()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
    
}

// MARK: - UITextViewDelegate

extension TaskEditorViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateDoneButtonVisibility()
    }
    
}
