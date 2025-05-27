//
//  TaskEditorPresenterTests.swift
//  ToDoAppTests
//
//  Created by Danil Otmakhov on 27.05.2025.
//

import XCTest
@testable import ToDoApp

final class MockTaskEditorView: TaskEditorViewProtocol {
    var reloadDataCalled = false
    var reloadDataViewModel: TaskEditorViewModel?
    var focusTitleFieldCalled = false
    var showErrorCalled = false
    var showErrorMessage: String?
    
    func reloadData(_ viewModel: TaskEditorViewModel) {
        reloadDataCalled = true
        reloadDataViewModel = viewModel
    }
    
    func focusTitleField() {
        focusTitleFieldCalled = true
    }
    
    func showError(_ message: String) {
        showErrorCalled = true
        showErrorMessage = message
    }
}

final class MockTaskEditorInteractor: TaskEditorInteractorInput {
    weak var output: TaskEditorInteractorOutput?
    
    var addTaskCalled = false
    var addTaskTitle: String?
    var addTaskDescription: String?
    var editCalled = false
    var editTask: Task?
    var editNewTitle: String?
    var editNewDescription: String?
    
    func addTask(title: String?, description: String?) {
        addTaskCalled = true
        addTaskTitle = title
        addTaskDescription = description
    }
    
    func edit(_ task: Task, newTitle: String?, newDescription: String?) {
        editCalled = true
        editTask = task
        editNewTitle = newTitle
        editNewDescription = newDescription
    }
}

final class MockTaskEditorRouter: TaskEditorRouterProtocol {
    var dismissEditorCalled = false
    
    func dismissEditor() {
        dismissEditorCalled = true
    }
}

final class TaskEditorPresenterTests: XCTestCase {
    
    var sut: TaskEditorPresenter!
    var mockView: MockTaskEditorView!
    var mockInteractor: MockTaskEditorInteractor!
    var mockRouter: MockTaskEditorRouter!
    var sampleTask: Task!
    
    override func setUpWithError() throws {
        mockView = MockTaskEditorView()
        mockInteractor = MockTaskEditorInteractor()
        mockRouter = MockTaskEditorRouter()
        sampleTask = Task(id: UUID(), title: "Sample Task", description: "Sample Description", createdAt: Date(), isCompleted: false)
        
        sut = TaskEditorPresenter(interactor: mockInteractor, task: nil)
        sut.view = mockView
        sut.router = mockRouter
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        sampleTask = nil
    }
    
    // MARK: - TaskEditorPresenterProtocol Tests
    
    func testViewDidLoadWithNewTaskCallsReloadDataAndFocusTitleField() {
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.reloadDataCalled)
        XCTAssertNotNil(mockView.reloadDataViewModel)
        XCTAssertNil(mockView.reloadDataViewModel?.title)
        XCTAssertNil(mockView.reloadDataViewModel?.description)
        XCTAssertNil(mockView.reloadDataViewModel?.dateString)
        XCTAssertTrue(mockView.focusTitleFieldCalled)
    }
    
    func testViewDidLoadWithExistingTaskCallsReloadDataWithoutFocus() {
        // Arrange
        sut = TaskEditorPresenter(interactor: mockInteractor, task: sampleTask)
        sut.view = mockView
        sut.router = mockRouter
        
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.reloadDataCalled)
        XCTAssertEqual(mockView.reloadDataViewModel?.title, "Sample Task")
        XCTAssertEqual(mockView.reloadDataViewModel?.description, "Sample Description")
        XCTAssertEqual(mockView.reloadDataViewModel?.dateString, sampleTask.createdAt.dateString)
        XCTAssertFalse(mockView.focusTitleFieldCalled)
    }
    
    func testDidTapDoneWithNewTaskCallsAddTaskAndDismiss() {
        // Arrange
        let title = "New Task"
        let description = "New Description"
        
        // Act
        sut.didTapDone(title: title, description: description)
        
        // Assert
        XCTAssertTrue(mockInteractor.addTaskCalled)
        XCTAssertEqual(mockInteractor.addTaskTitle, title)
        XCTAssertEqual(mockInteractor.addTaskDescription, description)
        XCTAssertTrue(mockRouter.dismissEditorCalled)
        XCTAssertFalse(mockInteractor.editCalled)
    }
    
    func testDidTapDoneWithExistingTaskCallsEditAndDismiss() {
        // Arrange
        sut = TaskEditorPresenter(interactor: mockInteractor, task: sampleTask)
        sut.view = mockView
        sut.router = mockRouter
        let newTitle = "Updated Task"
        let newDescription = "Updated Description"
        
        // Act
        sut.didTapDone(title: newTitle, description: newDescription)
        
        // Assert
        XCTAssertTrue(mockInteractor.editCalled)
        XCTAssertEqual(mockInteractor.editTask?.id, sampleTask.id)
        XCTAssertEqual(mockInteractor.editNewTitle, newTitle)
        XCTAssertEqual(mockInteractor.editNewDescription, newDescription)
        XCTAssertTrue(mockRouter.dismissEditorCalled)
        XCTAssertFalse(mockInteractor.addTaskCalled)
    }
    
    func testDidTapDoneWithEmptyTitleStillCallsAddTaskAndDismiss() {
        // Arrange
        let title: String? = nil
        let description = "Description"
        
        // Act
        sut.didTapDone(title: title, description: description)
        
        // Assert
        XCTAssertTrue(mockInteractor.addTaskCalled)
        XCTAssertNil(mockInteractor.addTaskTitle)
        XCTAssertEqual(mockInteractor.addTaskDescription, description)
        XCTAssertTrue(mockRouter.dismissEditorCalled)
    }
    
    // MARK: - TaskEditorInteractorOutput Tests
    
    func testDidFailToSaveTaskCallsShowError() {
        // Arrange
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // Act
        sut.didFailToSaveTask(with: error)
        
        // Assert
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, "Test error")
    }
}
